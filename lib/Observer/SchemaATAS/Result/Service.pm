use utf8;
package Observer::SchemaATAS::Result::Service;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::SchemaATAS::Result::Service

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

=head1 TABLE: C<service>

=cut

__PACKAGE__->table("service");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 subacct

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 service

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 manager

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 d_create

  data_type: 'date'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00'
  is_nullable: 0

=head2 d_change

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 startd

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 stopd

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 rperiod

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 blocked

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 undis

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 skimmed

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 pstartd

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 otv_manager

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 prepaid

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 drift

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 pid

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 dod

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 period_count

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 engine

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 reason

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 flag

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 speed_mult

  data_type: 'decimal'
  default_value: 1.00000
  is_nullable: 0
  size: [10,5]

=head2 agent_id

  data_type: 'bigint'
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
  "subacct",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "service",
  { data_type => "char", default_value => "", is_nullable => 0, size => 10 },
  "manager",
  { data_type => "char", default_value => "", is_nullable => 0, size => 16 },
  "d_create",
  {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00",
    is_nullable => 0,
  },
  "d_change",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "startd",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "stopd",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "rperiod",
  { data_type => "char", default_value => "", is_nullable => 0, size => 16 },
  "blocked",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "undis",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "skimmed",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "pstartd",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "otv_manager",
  { data_type => "char", default_value => "", is_nullable => 0, size => 16 },
  "prepaid",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "drift",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "pid",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "dod",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "period_count",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "engine",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "reason",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "flag",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "speed_mult",
  {
    data_type => "decimal",
    default_value => "1.00000",
    is_nullable => 0,
    size => [10, 5],
  },
  "agent_id",
  {
    data_type => "bigint",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZjbRkSEVxyLxOMHTruvPSQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
