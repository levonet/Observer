use utf8;
package Observer::Schema::ResultSet::Device;

=head1 NAME

Observer::Schema::ResultSet::Device

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Observer::Schema::ResultSet';

=head1 ACCESSORS

  DevId          accessor: 'dev_id' uint
  AreaHost       accessor: 'area_host' varchar(60)
  SrcHost        accessor: 'src_host' varchar(60)
  Community      accessor: 'community' varchar(64)
  DevName        accessor: 'dev_name' varchar(64)
  MAC            accessor: 'mac' char(12)
  Status         accessor: 'status' utinyint
  ErrId          accessor: 'err_id' uint
  UpdTime        accessor: 'upd_time' timestamp

=cut

my %status_vals = (
    VIEW_LOCK       => 0x00000001, # Игнорируется пользователем (и обходчиком)
    WALK_LOCK       => 0x00000002, # Игнорируется обходчиком
    WALK_INWORK     => 0x00000080, # Взято в работу обходчиком
    USER_NEWDEV     => 0x00000100, # Пользователь передал обходчику новое устройство
    USER_UPDDEV     => 0x00000200, # Пользователь запросил обновление по устройству (online), только системные данные и updtime
    USER_REQ_MASK   => 0x0000ff00, # Маска по которой фильтруем пользовательские запросы
    WRITE_MODE      => 0x00010000, # Разрешено изменение конфигурации коммутатора через snmp
    WALK_ERR_LOCK   => 0x01000000, # Ошибка обходчика, требует ручного снятия
    USER_ERR_LOCK   => 0x02000000, # Ошибка после запроса пользователя, требует ручного снятия
    LOCK_MASK       => 0x070000ff, # Используется для фильтрации при поиске задачи.
    WALK_DEV_MASK   => 0x0700ffff, # Маска для поиска устройств, по которым переодически обновляем маки
    CONNECT_ERROR   => 0x08000000, # Ошибка соединения с устройством (deprecated)
    DEBUG1          => 0x10000000, #
    DEBUG2          => 0x20000000, #
    DEBUG3          => 0x40000000, #
    DEBUG4          => 0x80000000, #
);

sub status_mask {
    my ( $self, $args, $val ) = @_;
    my $ret = $val || 0;

    return $ret unless defined $args;

    foreach ( keys %{$args} ) {
        if ( $args->{$_} == 0 ) {       # Убираем флаг
            $ret &= ~$status_vals{$_} if exists $status_vals{$_};
        } elsif ( $args->{$_} == 1 ) {  # Устанавливаем флаг
            $ret |= $status_vals{$_} if exists $status_vals{$_};
        }
    }

    return $ret;
}

sub status_is {
    my ( $self, $args, $val ) = @_;
    my $ret = $val || 0;

    return $ret unless defined $args;
    my $msk = 0;
    foreach ( @$args ) {
        $msk |= $status_vals{$_} if exists $status_vals{$_};
    }
    return $ret & $msk;
}

sub status_args {
    my ( $self, $args, $val ) = @_;
    my $ret = $val || 0;

    return $ret unless defined $args;

    if (exists $args->{-and} ) {
        my $mask = 0;
        foreach ( @{$args->{-and}} )
            { $mask |= $status_vals{$_} if exists $status_vals{$_}; }
        $ret &= $mask;
    }
    if (exists $args->{-or} )
        { foreach ( @{$args->{-or}} ) { $ret |= $status_vals{$_} if exists $status_vals{$_}; } }

    return $ret;
}

sub find_usertask {
    my ( $self, $area_host ) = @_;
    my $row = undef;

    $row = $self->search({
            AreaHost    => $area_host,
            -and        => [
                Status      => { '&' => $self->status_mask({ USER_REQ_MASK => 1 }) },
                -not_bool   => { Status => { '&' => $self->status_mask({ LOCK_MASK => 1 }) } },
            ],
        }, {
            select      => [ 'me.DevId', 'me.Status', 'me.UpdTime' ],
            order_by    => [ { -asc => [qw/ me.UpdTime /] } ],
            rows        => 1,
            for         => 'update',
        })->single;

    # not found work
    return undef unless defined $row;

    if ( $self->status_is([qw/WALK_INWORK/], $row->status) ) { # Paranoya 1
        $row->update({ Status => $self->status_mask({ DEBUG1 => 1 }, $row->status), });
        return undef;
    }

    # Захватываем устроийство
    $row->update({ Status => $self->status_mask({ WALK_INWORK => 1 }, $row->status), });
    $row = $self->find($row->id);

    unless ($self->status_is([qw/USER_REQ_MASK/], $row->status)) { # Paranoya 2
        $row->update({ Status => $self->status_mask({ DEBUG2 => 1, WALK_INWORK => 0 }, $row->status), });
        return undef;
    }

    return $row;
}

sub find_walkdev {
    my ( $self, $area_host, $upd_timeout ) = @_;
    my $row = undef;

    $row = $self->search({
            AreaHost    => $area_host,
            -not_bool   => { Status => { '&' => $self->status_mask({ WALK_DEV_MASK => 1 }) } },
            UpdTime     => { '<' => \[ "date_sub(now(), interval $upd_timeout)" ] },
        }, {
            select      => [ 'me.DevId', 'me.Status', 'me.UpdTime' ],
            order_by    => [ { -asc => [qw/ me.UpdTime /] } ],
            rows        => 1,
            for         => 'update',
        })->single;

    # not found work
    return undef unless defined $row;

    if ( $self->status_is([qw/WALK_INWORK/], $row->status) ) { # Paranoya 1
        $row->update({ Status => $self->status_mask({ DEBUG3 => 1 }, $row->status), });
        return undef;
    }

    # Захватываем устроийство
    $row->update({ Status => $self->status_mask({ WALK_INWORK => 1 }, $row->status), });

    return $self->find($row->id);
}

sub find_zombie {
    my ( $self, $area_host, $request_timeout ) = @_;
    my $row = undef;

    $row = $self->search({
            AreaHost    => $area_host,
            Status      => { '&' => $self->status_mask({ WALK_INWORK => 1 }) },
            UpdTime     => { '<' => \[ "date_sub(now(), interval $request_timeout)" ] },
        }, {
            select      => [ 'me.DevId', 'me.Status', 'me.UpdTime' ],
            order_by    => [ { -asc => [qw/ me.UpdTime /] } ],
            rows        => 1,
            for         => 'update',
        })->single;

    # not found work
    return undef unless defined $row;

    # Захватываем устроийство
    $row->update({
        Status => $self->status_mask({ WALK_INWORK => 1 }, $row->status),
        UpdTime => \'now()', #'
     });

    return $self->find($row->id);
}

sub area {
    my ( $self, $dev_id ) = @_;

    my $row = $self->search({ DevId => $dev_id }, { select => [ 'me.AreaHost' ] })->single;
    return defined $row ? $row->area_host : undef;
}

sub areas {
    my ( $self, $conditions ) = @_;

    return $self->search(
        $conditions,
        {
            select      => [ 'me.AreaHost' ],
            group_by    => [ 'me.AreaHost' ],
    });
}

sub hosts {
    my ( $self, $area_host, $upd_timeout, $adj_timeout ) = @_;

    return $self->search({
            AreaHost    => $area_host,
        }, {
             # { 'UNIX_TIMESTAMP' => [ 'me.DateCreat' ] },
             # { concat => [ { left => [ 'me.Description', 30 ] }, '" ..."' ] }
            select      => [ 'me.DevId', 'me.SrcHost',
#                             { '123' => { '>', { 'unix_timestamp' => [ 'me.UpdTime' ] } } }
                             \["(unix_timestamp(me.UpdTime) > (unix_timestamp(date_sub(now(), interval $upd_timeout))-$adj_timeout))"],
                             \["(me.Status & ".$self->status_mask({ USER_REQ_MASK => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ WALK_ERR_LOCK => 1, USER_ERR_LOCK => 1, CONNECT_ERROR => 1 }).")"],
                           ],
            as          => [ 'DevId', 'SrcHost', 'active', 'process', 'error' ],
            order_by    => [ { -asc => [qw/ me.SrcHost /] } ],
    });
}

sub info {
    my ( $self, $dev_id ) = @_;

    return $self->find($dev_id);
}

sub info_status {
    my ( $self, $dev_id ) = @_;

    return $self->search(
        { DevId => $dev_id },
        {
            select      => [
                             \["sec_to_time(unix_timestamp() - unix_timestamp(me.UpdTime))"],
                             \["(me.Status & ".$self->status_mask({ VIEW_LOCK => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ WALK_LOCK => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ WALK_INWORK => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ USER_NEWDEV => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ USER_UPDDEV => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ WRITE_MODE => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ WALK_ERR_LOCK => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ USER_ERR_LOCK => 1 }).")"],
                             \["(me.Status & ".$self->status_mask({ CONNECT_ERROR => 1 }).")"]
                           ],
            as          => [ 'last_upd', 'VIEW_LOCK', 'WALK_LOCK', 'WALK_INWORK', 'USER_NEWDEV', 'USER_UPDDEV', 'WRITE_MODE', 'WALK_ERR_LOCK', 'USER_ERR_LOCK', 'CONNECT_ERROR' ]
        }
    )->single;
}

sub delete_dev {
    my ( $self, $dev_id ) = @_;

    my $rs = $self->search({ DevId => $dev_id }, { rows => 1 });
    $rs->delete_all;

    return $rs;
}

sub findBy {
    my ( $self, $area_host, $src_host ) = @_;

    return $self->search({
            AreaHost => $area_host,
            SrcHost  => { -rlike => $src_host },
        }, {
            select   => [ 'me.DevId', 'me.AreaHost', 'me.SrcHost', 'me.UpdTime' ],
        });
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
