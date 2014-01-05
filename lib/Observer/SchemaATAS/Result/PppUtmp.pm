use utf8;
package Observer::SchemaATAS::Result::PppUtmp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::SchemaATAS::Result::PppUtmp

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

=head1 TABLE: C<ppp_utmp>

=cut

__PACKAGE__->table("ppp_utmp");

=head1 ACCESSORS

=head2 sesid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 psesid

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 login

  data_type: 'varbinary'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 subservice

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 line

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 NAS

  accessor: 'nas'
  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 ip

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 btime

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 etime

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 tel

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 19

=head2 asesid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 pasesid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 port_type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 price

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 suffix

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 provider

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 lim

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 agreement

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 category

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 8

=head2 called

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 19

=head2 service_id

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 realm

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 status

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 kill_num

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 sesident

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 period

  data_type: 'char'
  is_nullable: 0
  size: 50

=head2 period_etime

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "sesid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "psesid",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "login",
  { data_type => "varbinary", default_value => "", is_nullable => 0, size => 16 },
  "subservice",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "line",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "NAS",
  {
    accessor      => "nas",
    data_type     => "integer",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "ip",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "btime",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "etime",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "tel",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 19 },
  "asesid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "pasesid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "port_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "price",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "suffix",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "provider",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "lim",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "agreement",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "category",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 8 },
  "called",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 19 },
  "service_id",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "realm",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 16 },
  "status",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "kill_num",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "sesident",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "period",
  { data_type => "char", is_nullable => 0, size => 50 },
  "period_etime",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sesid>

=back

=cut

__PACKAGE__->set_primary_key("sesid");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-26 16:53:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D+9ZJltkdf5g/topMyM2cw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
