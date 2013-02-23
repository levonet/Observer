package Observer::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Observer::Controller::Root - Root Controller for Observer

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

    my $locale = $c->request->param('locale');
    $c->response->headers->push_header( 'Vary' => 'Accept-Language' );
    $c->languages( $locale ? [ $locale ] : undef );
}

=head2 index

The root page (/)

=cut

sub index : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("::i");

}

sub root : Chained('index') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("::r");
}

=head2 default

Standard 404 error page

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
