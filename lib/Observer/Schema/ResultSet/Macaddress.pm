use utf8;
package Observer::Schema::ResultSet::Macaddress;

=head1 NAME

Observer::Schema::ResultSet::Macaddress

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;
extends 'Observer::Schema::ResultSet';

=head1 ACCESSORS

  DevId          accessor: 'dev_id' uint
  Port           accessor: 'port' int
  MAC            accessor: 'mac' char(12)
  UpdStatus      accessor: 'upd_status' utinyint
  Service        accessor: 'service' varchar(32)
  UpdTime        accessor: 'upd_time' timestamp

=head2 UpdStatus values

  0 - поиск сервиса в последнюю очередь
  1 - поиск сервиса в первую очередь
  2 - (поиск не требуется)
  3 - присвоен сервис

=cut

sub view {
    my ( $self, $id ) = @_;

    return $self->search({
            'me.DevId'   => $id,
        }, {
            join    => { 'port' => { 'dev' } },
            select  => [ 'me.Port', 'me.MAC', 'me.Service', 'me.UpdTime',
                         \["(unix_timestamp(me.UpdTime) >= unix_timestamp(dev.UpdTime))"], ],
            as      => [ 'Port', 'MAC', 'Service', 'UpdTime', 'online' ],
        });
}

sub findBy {
    my ( $self, $area_host, $src_host, $mac ) = @_;

    my $cond = {
        'me.MAC'        => { -rlike => $mac },
        'dev.AreaHost'  => $area_host,
    };
    $cond->{'dev.SrcHost'} = { -rlike => $src_host } if defined $src_host;

    return $self->search( $cond,
        {
            join    => { 'port' => { 'dev' } },
            select  => [ 'me.DevId', 'me.Port', 'me.MAC', 'me.Service', 'me.UpdTime', 'dev.AreaHost', 'dev.SrcHost', 'port.IfStatus', 'port.IfName',
                         \["(unix_timestamp(me.UpdTime) >= unix_timestamp(dev.UpdTime))"], ],
            as      => [ 'DevId', 'Port', 'MAC', 'Service', 'UpdTime', 'AreaHost', 'SrcHost', 'IfStatus', 'IfName', 'online' ],
        });
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
