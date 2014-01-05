use utf8;
package Observer::SchemaATAS::ResultSet;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::ResultSet';

=head1 NAME

Observer::SchemaATAS::ResultSet

=head1 DESCRIPTION

Base class for all resultsets below the Observer::SchemaATAS::ResultSet::* namespace.

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
