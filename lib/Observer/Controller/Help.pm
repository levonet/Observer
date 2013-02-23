package Observer::Controller::Help;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Observer::Controller::Help - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 help

=cut

sub help : Chained('/index') PathPart('help') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("::h");
}

sub confsnmp : Chained('help') PathPart('confsnmp') Args(0) {
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
