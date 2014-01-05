use utf8;
package Observer::Schema::Result::Service;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::Schema::Result::Service

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

=head2 Login

  accessor: 'login'
  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 DeviceName

  accessor: 'device_name'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 Slot

  accessor: 'slot'
  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 SlotPort

  accessor: 'slot_port'
  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 RangePort

  accessor: 'range_port'
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
  "Login",
  { accessor => "login", data_type => "varchar", is_nullable => 0, size => 16 },
  "DeviceName",
  {
    accessor => "device_name",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 64,
  },
  "Slot",
  {
    accessor      => "slot",
    data_type     => "tinyint",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "SlotPort",
  {
    accessor      => "slot_port",
    data_type     => "tinyint",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "RangePort",
  {
    accessor      => "range_port",
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

=item * L</Login>

=back

=cut

__PACKAGE__->set_primary_key("Login");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-05-14 13:44:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pB5CVsrwjToaIUKFd6Ndmg

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(name => 'idx_DeviceName', fields => ['DeviceName']);
    $sqlt_table->add_index(name => 'idx_RangePort', fields => ['RangePort']);
    $sqlt_table->add_index(name => 'idx_UpdTime', fields => ['UpdTime']);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
