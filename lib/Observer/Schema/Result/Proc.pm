use utf8;
package Observer::Schema::Result::Proc;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::Schema::Result::Proc

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

=head1 TABLE: C<proc>

=cut

__PACKAGE__->table("proc");

=head1 ACCESSORS

=head2 AreaHost

  accessor: 'area_host'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 60

=head2 ProcId

  accessor: 'proc_id'
  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 LoopId

  accessor: 'loop_id'
  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 UpTime

  accessor: 'up_time'
  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 EvTime

  accessor: 'ev_time'
  data_type: 'time'
  default_value: '00:00:00'
  is_nullable: 0

=head2 EvName

  accessor: 'ev_name'
  data_type: 'varchar'
  is_nullable: 0
  size: 256

=cut

__PACKAGE__->add_columns(
  "AreaHost",
  {
    accessor => "area_host",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 60,
  },
  "ProcId",
  {
    accessor      => "proc_id",
    data_type     => "integer",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "LoopId",
  {
    accessor      => "loop_id",
    data_type     => "integer",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "UpTime",
  {
    accessor => "up_time",
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "EvTime",
  {
    accessor      => "ev_time",
    data_type     => "time",
    default_value => "00:00:00",
    is_nullable   => 0,
  },
  "EvName",
  {
    accessor => "ev_name",
    data_type => "varchar",
    is_nullable => 0,
    size => 256,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</AreaHost>

=item * L</ProcId>

=item * L</LoopId>

=back

=cut

__PACKAGE__->set_primary_key("AreaHost", "ProcId", "LoopId");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-16 21:45:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2uagQTDqGBoa13vA/KvYBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
