use utf8;
package Observer::SchemaATAS::Result::Device;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::SchemaATAS::Result::Device

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

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 point

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 device_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 device_id

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 device_type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 ip_subgrp

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 slot

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 port_type

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 8

=head2 port_num

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 first_port

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 0

=head2 cross_pair

  data_type: 'smallint'
  default_value: -1
  is_nullable: 0

=head2 cross_pairs

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 128

=head2 comment

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 manager

  data_type: 'char'
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

=head2 serv_type

  data_type: 'char'
  default_value: 'UNKNOWN'
  is_nullable: 0
  size: 8

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "point",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "device_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
  "device_id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
  "device_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "ip_subgrp",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "slot",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "port_type",
  { data_type => "char", default_value => "", is_nullable => 0, size => 8 },
  "port_num",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "first_port",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "cross_pair",
  { data_type => "smallint", default_value => -1, is_nullable => 0 },
  "cross_pairs",
  { data_type => "char", default_value => "", is_nullable => 0, size => 128 },
  "comment",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "manager",
  { data_type => "char", default_value => "", is_nullable => 0, size => 16 },
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
  "serv_type",
  {
    data_type => "char",
    default_value => "UNKNOWN",
    is_nullable => 0,
    size => 8,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<ds>

=over 4

=item * L</device_name>

=item * L</slot>

=back

=cut

__PACKAGE__->add_unique_constraint("ds", ["device_name", "slot"]);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-26 16:53:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aDrs5Cjv5CsJuZQ4StGbAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
