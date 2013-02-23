use utf8;
package Observer::Schema::Result::Port;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Observer::Schema::Result::Port

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

=head1 TABLE: C<ports>

=cut

__PACKAGE__->table("ports");

=head1 ACCESSORS

=head2 DevId

  accessor: 'dev_id'
  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 Port

  accessor: 'port'
  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 IfStatus

  accessor: 'if_status'
  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 IfIndex

  accessor: 'if_index'
  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 IfName

  accessor: 'if_name'
  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 IfType

  accessor: 'if_type'
  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 IfSpeed

  accessor: 'if_speed'
  data_type: 'integer'
  default_value: 0
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
    accessor       => "dev_id",
    data_type      => "integer",
    extra          => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Port",
  {
    accessor      => "port",
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 0,
  },
  "IfStatus",
  {
    accessor      => "if_status",
    data_type     => "tinyint",
    default_value => 0,
    extra         => { unsigned => 1 },
    is_nullable   => 0,
  },
  "IfIndex",
  {
    accessor      => "if_index",
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 0,
  },
  "IfName",
  { accessor => "if_name", data_type => "varchar", is_nullable => 0, size => 64 },
  "IfType",
  { accessor => "if_type", data_type => "varchar", is_nullable => 0, size => 32 },
  "IfSpeed",
  {
    accessor      => "if_speed",
    data_type     => "integer",
    default_value => 0,
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

=item * L</Port>

=back

=cut

__PACKAGE__->set_primary_key("DevId", "Port");

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

=head2 macaddresses

Type: has_many

Related object: L<Observer::Schema::Result::Macaddress>

=cut

__PACKAGE__->has_many(
  "macaddresses",
  "Observer::Schema::Result::Macaddress",
  { "foreign.DevId" => "self.DevId", "foreign.Port" => "self.Port" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-26 16:43:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BjACqTFjE1yi5GzJb6Qdbg

my %status_vals = (
    ADMIN_MASK      => 0x0003, # Статус порта, административный
    OPER_MASK       => 0x001c, # Статус порта, текущий
    OPER_OFFSET     => 2,      # 
    NOT_MONITORING  => 0x0020, # Маркер транкового порта (пока на нем не собираем маки)
);

sub status_val {
    my ( $self, $val ) = @_;

    return $status_vals{$val};
}

sub status_mask {
    my ( $self, $args ) = @_;

    my $ret = $self->if_status;

    return $ret unless defined $args;

    foreach ( keys %{$args} ) {
        if ( $args->{$_} == 0 ) {       # Убираем флаг
            $ret &= ~$status_vals{$_} if exists $status_vals{$_};
        } elsif ( $args->{$_} == 1 ) {  # Устанавливаем флаг
            $ret |= $status_vals{$_} if exists $status_vals{$_};
        }
    }

    return $ret;
}

sub admin_status {
    my ( $self ) = @_;

    my %values = (
        0 => 'undef',
        1 => 'up',
        2 => 'down',
        3 => 'testing',
    );

    return $values{$self->if_status & $status_vals{ADMIN_MASK}};
}

sub oper_status {
    my ( $self ) = @_;

    my %values = (
        0 => 'undef',
        1 => 'up',
        2 => 'down',
        3 => 'testing',
        4 => 'unknown',
        5 => 'dormant',
        6 => 'notPresent',
        7 => 'lowerLayerDown',
    );

    return $values{($self->if_status & $status_vals{OPER_MASK}) >> $status_vals{OPER_OFFSET}};
}

sub is_monitoring {
    my ( $self ) = @_;

    return not ($self->if_status & $status_vals{NOT_MONITORING});
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
