use utf8;
package Observer::SchemaATAS::Result::Point;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::SchemaATAS::Result::Point

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

=head1 TABLE: C<point>

=cut

__PACKAGE__->table("point");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 city

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 num

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 16

=head2 addr

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 150

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

=head2 block_type

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 1

=head2 block_porch

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 block_floor

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 block_flat

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 street_type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 street

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 block

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 block_letter

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 1

=head2 porch

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 build

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 adr_comment

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "city",
  { data_type => "char", default_value => "", is_nullable => 0, size => 16 },
  "num",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 16 },
  "addr",
  { data_type => "char", default_value => "", is_nullable => 0, size => 150 },
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
  "block_type",
  { data_type => "char", default_value => "", is_nullable => 0, size => 1 },
  "block_porch",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "block_floor",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "block_flat",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "street_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "street",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
  "block",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "block_letter",
  { data_type => "char", default_value => "", is_nullable => 0, size => 1 },
  "porch",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "build",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "adr_comment",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<cn>

=over 4

=item * L</city>

=item * L</num>

=back

=cut

__PACKAGE__->add_unique_constraint("cn", ["city", "num"]);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-26 16:53:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cg2E5qVsObDjLwQhw5FMWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
