use utf8;
package Observer::Schema::Result::Device;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::Schema::Result::Device

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

=head1 TABLE: C<device>

=cut

__PACKAGE__->table("device");

=head1 ACCESSORS

=head2 DevId

  accessor: 'dev_id'
  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 AreaHost

  accessor: 'area_host'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 60

=head2 SrcHost

  accessor: 'src_host'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 60

=head2 Community

  accessor: 'community'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 DevName

  accessor: 'dev_name'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 MAC

  accessor: 'mac'
  data_type: 'char'
  default_value: 000000000000
  is_nullable: 0
  size: 12

=head2 Status

  accessor: 'status'
  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 ErrId

  accessor: 'err_id'
  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

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
    accessor => "dev_id",
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "AreaHost",
  {
    accessor => "area_host",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 60,
  },
  "SrcHost",
  {
    accessor => "src_host",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 60,
  },
  "Community",
  {
    accessor => "community",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 64,
  },
  "DevName",
  {
    accessor => "dev_name",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 64,
  },
  "MAC",
  {
    accessor => "mac",
    data_type => "char",
    default_value => "000000000000",
    is_nullable => 0,
    size => 12,
  },
  "Status",
  {
    accessor      => "status",
    data_type     => "integer",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "ErrId",
  {
    accessor      => "err_id",
    data_type     => "integer",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
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

=back

=cut

__PACKAGE__->set_primary_key("DevId");

=head1 RELATIONS

=head2 errorlogs

Type: has_many

Related object: L<Observer::Schema::Result::Errorlog>

=cut

__PACKAGE__->has_many(
  "errorlogs",
  "Observer::Schema::Result::Errorlog",
  { "foreign.DevId" => "self.DevId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ports

Type: has_many

Related object: L<Observer::Schema::Result::Port>

=cut

__PACKAGE__->has_many(
  "ports",
  "Observer::Schema::Result::Port",
  { "foreign.DevId" => "self.DevId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-11 10:48:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QsD6qz5WmjSzoDhFoFaV9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
