use utf8;
package Observer::Schema::ResultSet::Port;

=head1 NAME

Observer::Schema::ResultSet::Port

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Observer::Schema::ResultSet';

=head1 ACCESSORS

  DevId          accessor: 'dev_id' uint
  Port           accessor: 'port' int
  IfStatus       accessor: 'if_status' utinyint
  IfIndex        accessor: 'if_index' int
  IfName         accessor: 'if_name' varchar(64)
  IfType         accessor: 'if_type' varchar(32)
  IfSpeed        accessor: 'if_speed' int
  UpdTime        accessor: 'upd_time' timestamp

=cut

my %status_vals = (
    ADMIN_MASK      => 0x0003, # Статус порта, административный
    OPER_MASK       => 0x001c, # Статус порта, текущий
    OPER_OFFSET     => 2,      # 
    NOT_MONITORING  => 0x0020, # Маркер транкового порта (пока на нем не собираем маки)
);

sub status_val {
    my ( $self, $val ) = @_;

    return $status_vals{$val};
}

sub ifAdminStatus {
    my ( $self, $id ) = @_;
    my %values = (
        1 => 'up',
        2 => 'down',
        3 => 'testing'
    );

    return "boo";
}

sub ifOperStatus {
    my ( $self, $id ) = @_;
    my %values = (
        1 => 'up',
        2 => 'down',
        3 => 'testing',
        4 => 'unknown',
        5 => 'dormant',
        6 => 'notPresent',
        7 => 'lowerLayerDown'
    );

    return $values{$id} || 'unknown';
}

sub empty {
    my ( $self, $dev_id ) = @_;

    my $row = $self->search(
        { DevId => $dev_id },
        {
            select      => [ \[ 'count(1)' ] ],
            as          => [ 'cnt' ]
        }
    )->single;

    return not $row->get_column('cnt');
}

sub ports {
    my ( $self, $dev_id ) = @_;

    return $self->search(
        { DevId => $dev_id },
        {
            select      => [ 'me.Port', 'me.IfIndex', 'me.IfName', 'me.IfType', 'me.IfSpeed',
                             \["me.IfStatus & ".$self->status_val('ADMIN_MASK')],
                             \["(me.IfStatus & ".$self->status_val('OPER_MASK').") >> ".$self->status_val('OPER_OFFSET')],
                             \["not (me.IfStatus & ".$self->status_val('NOT_MONITORING').")"],
                           ],
            as          => [ 'Port', 'IfIndex', 'IfName', 'IfType', 'IfSpeed', 'IfAdminStatus', 'IfOperStatus', 'isMonitoring'],
            order_by    => [ { -asc => [qw/ me.Port /] } ],
        }
    );
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
