use utf8;
package Observer::SchemaATAS::Result::Port;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::SchemaATAS::Result::Port

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

=head1 TABLE: C<port>

=cut

__PACKAGE__->table("port");

=head1 ACCESSORS

=head2 mile_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 device

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 port

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 comment

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 status

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 8

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

=cut

__PACKAGE__->add_columns(
  "mile_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "device",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "port",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "comment",
  { data_type => "char", default_value => "", is_nullable => 0, size => 32 },
  "status",
  { data_type => "char", default_value => "", is_nullable => 0, size => 8 },
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
);

=head1 PRIMARY KEY

=over 4

=item * L</device>

=item * L</port>

=back

=cut

__PACKAGE__->set_primary_key("device", "port");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-26 16:53:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2tgttpnFw+cXoUEjklJY7g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
