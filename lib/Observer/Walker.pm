package Observer::Walker;
use Moose;
use namespace::autoclean;
{
  $Observer::Walker::VERSION = '0.20130126';
}

use Config;
use Observer::Walker::SNMP;

has config      => ( is => 'ro' );
has schema      => ( is => 'ro' );
has procid      => ( is => 'ro', isa => 'Int', default => 0 );
has loopid      => ( is => 'ro', isa => 'Int', default => 0 );

has snmp        => ( is => 'rw' );
has dev_status  => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
        status_set      => 'set',
        status_pairs    => 'kv',
        status_clear    => 'clear',
    },
);

has task_counter=> ( is => 'rw', isa => 'Int', default => 0 );
has task_last   => ( is => 'rw', isa => 'Str', default => "" );
has error_id    => ( is => 'rw', isa => 'Int', default => 0 );

sub prepare {
    my $self = shift;
}

#sub version {
#    my $self = shift;
#
#    return $VERSION;
#}

sub status {
    my $self = shift;
    my $ret = {};

    foreach my $pair ($self->status_pairs) {
        $ret->{$pair->[0]} = $pair->[1];
    }

    return $ret;
}

sub BUILD {
    my $self = shift;

    $self->snmp(Observer::Walker::SNMP->new( config  => $self->config ));
}

sub close {
    my ( $self ) = @_;

    # Очищаем таблицу proc
    my $rs = $self->schema->resultset('Proc')->find({
        AreaHost        => $self->config->{'area_host'},
        ProcId          => $self->procid,
        LoopId          => $self->loopid,
    });
    $rs->delete if $rs;
}

sub taskbegin {
    my ( $self, $cur, $msg ) = @_;

    if ($cur ne $self->task_last) {
         $self->task_last($cur);
         $self->task_counter(1);
    }

    my $row = $self->schema->resultset('Proc')->update_or_new({
        AreaHost        => $self->config->{'area_host'},
        ProcId          => $self->procid,
        LoopId          => $self->loopid,
        UpTime          => \'now()', #'
        EvTime          => '00:00:00',
        EvName          => $cur.'['.$self->task_counter.'], '.$msg,
    });

    $row->insert unless $row->in_storage;
}

sub taskend {
    my ( $self ) = @_;

    my $row = $self->schema->resultset('Proc')->find({
        AreaHost        => $self->config->{'area_host'},
        ProcId          => $self->procid,
        LoopId          => $self->loopid,
    });

    $row->update({
        EvTime  => \'sec_to_time(unix_timestamp()-unix_timestamp(UpTime))', #'
        EvName  => \'concat(EvName,", END")', #'
    });

    if ( (exists $self->config->{max_task_repeat}->{$self->task_last} &&
            $self->task_counter > $self->config->{max_task_repeat}->{$self->task_last}) ||
            ! exists $self->config->{max_task_repeat}->{$self->task_last} ) {
        $self->task_counter(0);
        return 0;
    }

    return $self->task_counter( $self->task_counter + 1 );
}

sub error {
    my ( $self, $devrow, $msg ) = @_;

    my $rs = $self->schema->resultset('Errorlog')->create({
        DevId   => $devrow->id,
        EvTime  => \['now()'],
        Message => $msg,
    });

    $devrow->update({
        ErrId   => $rs->err_id,
    });

    $self->error_id($rs->err_id);
}

sub error_clean {
    my ( $self, $devrow ) = @_;

    $devrow->update({ ErrId => 0 });

    $self->error_id(0);
}

sub do_walk {
    my $self = shift;

    my $row = undef;

    #=================================================================
    # сначала выполняем высокоприоритетные (пользовательские операции)
    #
    $row = $self->schema->resultset('Device')->find_usertask($self->config->{'area_host'});
    if ($row) {
        $self->status_clear;
        $self->status_set( WALK_INWORK => 0, CONNECT_ERROR => 0 );
        $self->error_clean($row);

        #------------------------------------------------
        # Пользователь передал обходчику новое устройство
        #
        if ($self->schema->resultset('Device')->status_is([qw/USER_NEWDEV/], $row->status)) {

            $self->taskbegin('usertask', "NewDevice(id:".$row->id.", host:".$row->src_host.")");

            if ($self->snmp->connect({
                        -hostname   => $row->src_host,
                        -community  => $row->community,
                    })) {

                $self->newdevice($row);

                $self->snmp->close;
            } else {
                # убираем из пула задачь, обновляем время, чтоб не было зацикливания
                # пользователь может вернуть обратно [попробовать снова]
                $self->status_set(WALK_LOCK => 1);
                $self->status_set(CONNECT_ERROR => 1);
                $self->error($row, $self->snmp->error);
            }

        #-------------------------------------------------------------------------
        # Пользователь запросил обновление по устройству, только системные данные,
        # позволяет подтвердить состояние online, mac, статус портов
        #
        } elsif ($self->schema->resultset('Device')->status_is([qw/USER_UPDDEV/], $row->status)) {

            $self->taskbegin('usertask', "UpdDevice(id:".$row->id.", host:".$row->src_host.", name:".$row->dev_name.")");

            if ($self->snmp->connect({
                        -hostname   => $row->src_host,
                        -community  => $row->community,
                    })) {

                $self->walkdevice($row);

                $self->snmp->close;
            } else {
                $self->status_set(CONNECT_ERROR => 1);
                $self->error($row, $self->snmp->error);
            }

        } else {
            $self->taskbegin('error', sprintf("Error(id:%i, host: %s, status: %08x)", $row->id, $row->src_host, $row->status));
            $self->status_set(WALK_LOCK => 1);
            # убираем из пула задачь, обновляем время, чтоб не было зацикливания
            $self->error($row, "Wrong status in `Device` table");
        }

        unless ($self->error_id) {
            $self->status_set(USER_REQ_MASK => 0);
        }

        # Снимаем флаги
        $row->update({
            Status  => $self->schema->resultset('Device')->status_mask($self->status, $row->status),
            UpdTime => \'now()', #'
        });

        # если все удачно, то переходим в начало цикла, возможно есть еще
        return 0 if $self->taskend;
    }

    #====================================================
    # теперь низкоприоритетные (сбор и обновление данных)
    #

    #--------------------------------------------
    # Обновление статуса портов, сбор MAC-адресов
    #
    $row = $self->schema->resultset('Device')->find_walkdev($self->config->{'area_host'}, $self->config->{'update_device_timeout'});
    if ($row) {
        $self->status_clear;
        $self->status_set( WALK_INWORK => 0, CONNECT_ERROR => 0 );
        $self->error_clean($row);

        $self->taskbegin('walkdevice', "WalkDevice(id:".$row->id.", host:".$row->src_host.", name:".$row->dev_name.")");

        if ($self->snmp->connect({
                    -hostname   => $row->src_host,
                    -community  => $row->community,
                })) {

            $self->walkdevice($row);

            $self->snmp->close;
        } else {
            $self->status_set(CONNECT_ERROR => 1);
            $self->error($row, $self->snmp->error);
        }

        # Снимаем флаги
        $row->update({
            Status  => $self->schema->resultset('Device')->status_mask($self->status, $row->status),
            UpdTime => \'now()', #'
        });

        # если все удачно, то переходим в начало цикла, возможно есть еще
        return 0 if $self->taskend;
    }

    #---------------------------------
    # Привязка сервиса к порту по маку
    #
    # делаем выборку по свежим макам (старые не смотрим) за короткий интервал = хранению на статадме / 2
    # проверенные и не найденные маки помечаем до следующего обновления, чтоб не проверять их повторно
    # (релевантность = свежесть и меньшее кол-во на порту)
    # нужно проверить: освежение мака за счет плавающей скорости на порту, при этом сессия не соединяется заново
#    if (defined $row) {
#        $self->taskbegin('findservice', "");

        # если все удачно, то переходим в начало цикла, возможно есть еще
#        return 0 if $self->taskend;
#    }
    #---------------------------------------------------------
    # Сопоставление портов фактического и на statadm по логину
    # (возможно включить это в "привязку сервиса")


    #==================================
    # чистка базы (раз в день например)
    #

    #-----------------------------------------------------------------
    # Снимаем блокировки по таймауту в случае аварий завершения демона
    #
    $row = $self->schema->resultset('Device')->find_zombie($self->config->{'area_host'}, $self->config->{'request_timeout'});
    if ($row) {
        $self->status_clear;
        $self->status_set( WALK_INWORK => 0, CONNECT_ERROR => 0 );

        $self->taskbegin('walkdevice', "KillZombie(id:".$row->id.", host:".$row->src_host.", name:".$row->dev_name.")");

        $row->update({
            Status  => $self->schema->resultset('Device')->status_mask($self->status, $row->status),
            UpdTime => \'now()', #'
            ErrId   => 0,
        });

        return 0 if $self->taskend;
    }

    # удаляем маки которые не появлялись на портах более (n) месяцев.
#    {
        # return 0; может накопилось
#    }

    # Если добрались до конца то, говорим, что можем поспать
    return 1;
}

sub newdevice {
    my ( $self, $row ) = @_;
    my $vals = {};

    $vals->{MAC} = $self->snmp->MAC;
    unless (defined $vals->{MAC}) {
        # первая ошибка соединения проявится здесь `No response from remote host "hostname"`
        $self->status_set(CONNECT_ERROR => 1) if $self->snmp->error =~ m/No response from remote host/;
        $self->status_set(WALK_LOCK => 1);
        $self->error($row, $self->snmp->error);
        return;
    }
    $vals->{DevName} = $self->snmp->device_name;
    unless (defined $vals->{DevName}) {
        $self->status_set(WALK_LOCK => 1);
        $self->error($row, $self->snmp->error);
        return;
    }

    $row->update($vals);

    # Получаем порты устройства
    my $ports = $self->snmp->ports($row->dev_name);
    unless (defined $ports) {
        $self->status_set(WALK_LOCK => 1);
        $self->error($row, $self->snmp->error);
        return;
    }

    # Проверяем наличие таблицы портов у устройства в БД, если нет, то ОК
    unless ($self->schema->resultset('Port')->empty($row->id)) {
        # Очевидно реинкарнация
        # (пытаемся добавить существующее устройство)
        # чистим информацию по порту
        # и создаем порты заново
        $row->ports->delete_all;
    }

    # Создаем порты
    foreach (sort { $a <=> $b } keys %{$ports}) {
        $self->schema->resultset('Port')->create({
            DevId       => $row->id,
            Port        => $_,
            IfStatus    => $ports->{$_}->{ifAdminStatus} | ($ports->{$_}->{ifOperStatus} << $self->schema->resultset('Port')->status_val('OPER_OFFSET')),
            IfIndex     => $ports->{$_}->{ifIndex},
            IfName      => $ports->{$_}->{ifName},
            IfType      => $ports->{$_}->{ifType},
            IfSpeed     => $ports->{$_}->{ifSpeed},
            UpdTime     => \'now()', #'
        });
    }

    # Получаем MAC-адреса устройства
    my $macs = $self->snmp->macs($row->dev_name, $ports);
    unless (defined $macs) {
        $self->status_set(WALK_LOCK => 1);         # только в случае newdev
        $self->error($row, $self->snmp->error);
        return;
    }

    # Добавляем в БД маки
    foreach my $row_port ($row->ports->all) {

        # Помечаем порт как не мониторящийся если MACs >= max_mac_to_port
        if ( exists $self->config->{max_mac_to_port} &&
                $self->config->{max_mac_to_port} > 0 &&
                ($#{$macs->{$row_port->port}}+1) > $self->config->{max_mac_to_port} ) {

            $row_port->update({
                IfStatus => $row_port->status_mask({NOT_MONITORING => 1}),
            });

        } else {

            # Иначе добавляем маки (чистим от повторений)
            my %tmp;
            foreach (grep{!$tmp{$_}++} @{$macs->{$row_port->port}}) {
                $self->schema->resultset('Macaddress')->create({
                    DevId       => $row->id,
                    Port        => $row_port->port,
                    MAC         => $_,
                    UpdStatus   => 0,
                    UpdTime     => \'now()', #'
                });
            }

        }
    }
}

sub walkdevice {
    my ( $self, $row ) = @_;

    my $mac = $self->snmp->MAC;
    unless (defined $mac) {
        # первая ошибка соединения проявится здесь `No response from remote host "hostname"`
        $self->status_set(CONNECT_ERROR => 1) if $self->snmp->error =~ m/No response from remote host/;
        $self->error($row, $self->snmp->error);
        return;
    }

    # Проверяем мак устройства
    #    если не соответствует, блокируем устройство
    if ($mac ne $row->mac) {
        $self->status_set(WALK_LOCK => 1);
        $self->error($row, "Changed device MAC-address. Device MAC in DB: ".$row->mac.", real MAC: ".$mac);
        return;
    }

    # Получаем порты устройства, по которым будем запрашивать статус
    my $ports = {};
    foreach my $row_port ($row->ports->all) {
        $ports->{$row_port->port}->{row} = $row_port;
        $ports->{$row_port->port}->{ifIndex} = $row_port->if_index;
        $ports->{$row_port->port}->{oldIfStatus} = $row_port->if_status;
        $ports->{$row_port->port}->{statusFlags} = $row_port->status_mask({ADMIN_MASK => 0, OPER_MASK => 0});
        $ports->{$row_port->port}->{oldIfSpeed} = $row_port->if_speed;
    }

    # Получаем статус портов с устройства
    unless ($self->snmp->ports_dynamic_status($ports)) {
        $self->error($row, $self->snmp->error);
        return;
    }

    # Получаем MAC-адреса устройства
    my $macs = $self->snmp->macs($row->dev_name, $ports);
    unless (defined $macs) {
        $self->error($row, $self->snmp->error);
        return;
    }

    foreach (keys %{$ports}) {
        # Статус должен складываться из старого <= обновляем новое
        my $ifstatus = $ports->{$_}->{statusFlags} | $ports->{$_}->{ifAdminStatus} |
                ($ports->{$_}->{ifOperStatus} << $self->schema->resultset('Port')->status_val('OPER_OFFSET'));

        # Если админстатус стал down, удаляем маки на порту(если есть) и сбрасываем флаг "не мониторинга" маков
        if ($ports->{$_}->{row}->admin_status ne 'down' &&
            $ports->{$_}->{ifAdminStatus} == 2 ) {      # == 'down'

            $ports->{$_}->{row}->macaddresses->delete_all;
            $ifstatus &= ~($self->schema->resultset('Port')->status_val('NOT_MONITORING'));
# todo проверить
        }

        my $row_port = undef;
        # обновляем порт только в случае изменения
        if ($ifstatus != $ports->{$_}->{oldIfStatus} ||
            $ports->{$_}->{ifSpeed} != $ports->{$_}->{oldIfSpeed}) {

            $row_port = $ports->{$_}->{row}->update({
                IfStatus    => $ifstatus,
                IfSpeed     => $ports->{$_}->{ifSpeed},
                UpdTime     => \'now()', #'
            });

            $ports->{$_}->{update_mac} = 1 if $row_port->oper_status ne 'down';
        }

        $row_port ||= $ports->{$_}->{row};
        my $port_id = $_;

        # Обходим MAC-и
        if ($row_port->oper_status eq 'up' &&
            $row_port->is_monitoring) {

            # Помечаем порт как не мониторящийся если MACs >= max_mac_to_port
            if ( exists $self->config->{max_mac_to_port} &&
                $self->config->{max_mac_to_port} > 0 &&
                ($#{$macs->{$row_port->port}}+1) > $self->config->{max_mac_to_port} ) {

                $row_port->update({
                    IfStatus => $row_port->status_mask({NOT_MONITORING => 1}),
                    UpdTime     => \'now()', #'
                });

            } else {

                foreach (@{$macs->{$row_port->port}}) {

                    unless (my $row_mac = $row_port->macaddresses->search({MAC => $_})->single) {

                        # Добавляем мак, если он отсутствует в базе
                        $self->schema->resultset('Macaddress')->create({
                            DevId       => $row->id,
                            Port        => $row_port->port,
                            MAC         => $_,
                            UpdStatus   => 1,
                            UpdTime     => \'now()', #'
                        });

                    } else {

                        # Обновляем статус существующих портов
                        my $cond = {
                            UpdStatus => (exists $ports->{$port_id}->{update_mac}) ? 1 : 0,
                        };
                        $cond->{UpdTime} = \'now()'; #'
                        $row_mac->update($cond) if $row_mac->upd_status < 2;
                    }
                }
            }
        }
    }
}

=head1 NAME

Observer::Walker - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
