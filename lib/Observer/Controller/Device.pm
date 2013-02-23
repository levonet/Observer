package Observer::Controller::Device;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Observer::Controller::Device - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub device : Chained('/index') PathPart('device') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current_view} = 'HTML';
    $c->log->debug("::d");
}

sub addtab : Chained('device') PathPart('addtab') Args(0) {
    my ( $self, $c ) = @_;

}

sub find : Chained('device') PathPart('find') Args(0) {
    my ( $self, $c ) = @_;

}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
