use utf8;
package Observer::Schema::Result::Macaddress;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::Schema::Result::Macaddress

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<macaddress>

=cut

__PACKAGE__->table("macaddress");

=head1 ACCESSORS

=head2 DevId

  accessor: 'dev_id'
  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 Port

  accessor: 'port'
  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 MAC

  accessor: 'mac'
  data_type: 'char'
  default_value: 000000000000
  is_nullable: 0
  size: 12

=head2 UpdStatus

  accessor: 'upd_status'
  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 Service

  accessor: 'service'
  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 UpdTime

  accessor: 'upd_time'
  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "DevId",
  {
    accessor       => "dev_id",
    data_type      => "integer",
    extra          => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Port",
  {
    accessor       => "port",
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "MAC",
  {
    accessor => "mac",
    data_type => "char",
    default_value => "000000000000",
    is_nullable => 0,
    size => 12,
  },
  "UpdStatus",
  {
    accessor      => "upd_status",
    data_type     => "tinyint",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "Service",
  { accessor => "service", data_type => "varchar", is_nullable => 0, size => 32 },
  "UpdTime",
  {
    accessor => "upd_time",
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</DevId>

=item * L</Port>

=item * L</MAC>

=back

=cut

__PACKAGE__->set_primary_key("DevId", "Port", "MAC");

=head1 RELATIONS

=head2 port

Type: belongs_to

Related object: L<Observer::Schema::Result::Port>

=cut

__PACKAGE__->belongs_to(
  "port",
  "Observer::Schema::Result::Port",
  { DevId => "DevId", Port => "Port" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-03 01:02:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yVYWycFubaIEHm5OkiiyOw

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(name => 'idx_DevId_Port', fields => ['DevId', 'Port']);
    $sqlt_table->add_index(name => 'idx_MAC', fields => ['MAC']);
    $sqlt_table->add_index(name => 'idx_UpdStatus', fields => ['UpdStatus']);
    $sqlt_table->add_index(name => 'idx_Service', fields => ['Service']);
    $sqlt_table->add_index(name => 'idx_UpdTime', fields => ['UpdTime']);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
