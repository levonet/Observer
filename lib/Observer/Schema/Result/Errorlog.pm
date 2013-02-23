use utf8;
package Observer::Schema::Result::Errorlog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::Schema::Result::Errorlog

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

=head1 TABLE: C<errorlog>

=cut

__PACKAGE__->table("errorlog");

=head1 ACCESSORS

=head2 ErrId

  accessor: 'err_id'
  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 DevId

  accessor: 'dev_id'
  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 EvTime

  accessor: 'ev_time'
  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 Message

  accessor: 'message'
  data_type: 'varchar'
  is_nullable: 0
  size: 256

=cut

__PACKAGE__->add_columns(
  "ErrId",
  {
    accessor => "err_id",
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "DevId",
  {
    accessor       => "dev_id",
    data_type      => "integer",
    extra          => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "EvTime",
  {
    accessor => "ev_time",
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "Message",
  {
    accessor => "message",
    data_type => "varchar",
    is_nullable => 0,
    size => 256,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</ErrId>

=back

=cut

__PACKAGE__->set_primary_key("ErrId");

=head1 RELATIONS

=head2 dev

Type: belongs_to

Related object: L<Observer::Schema::Result::Device>

=cut

__PACKAGE__->belongs_to(
  "dev",
  "Observer::Schema::Result::Device",
  { DevId => "DevId" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-24 12:43:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uuxuvou2lMouQGSRCP2c+Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
