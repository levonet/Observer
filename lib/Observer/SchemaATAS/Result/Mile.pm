use utf8;
package Observer::SchemaATAS::Result::Mile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::SchemaATAS::Result::Mile

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

=head1 TABLE: C<mile>

=cut

__PACKAGE__->table("mile");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 transit_type

  data_type: 'tinyint'
  is_nullable: 0

=head2 transit

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 transit_owner

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 transit_num

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 city

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 addr

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 point_prov_addr

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 status

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 0

=head2 MAC_limit

  accessor: 'mac_limit'
  data_type: 'integer'
  default_value: 2
  extra: {unsigned => 1}
  is_nullable: 0

=head2 manager

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 d_create

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 d_change

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 speed_in

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 speed_out

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "type",
  { data_type => "char", default_value => "", is_nullable => 0, size => 10 },
  "transit_type",
  { data_type => "tinyint", is_nullable => 0 },
  "transit",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "transit_owner",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "transit_num",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "city",
  { data_type => "char", default_value => "", is_nullable => 0, size => 50 },
  "addr",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "point_prov_addr",
  { data_type => "char", default_value => "", is_nullable => 0, size => 16 },
  "status",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "MAC_limit",
  {
    accessor      => "mac_limit",
    data_type     => "integer",
    default_value => 2,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "manager",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 16 },
  "d_create",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "d_change",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "speed_in",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "speed_out",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-26 16:53:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zdvj0tc/hUrT7VYW8kH5eA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
