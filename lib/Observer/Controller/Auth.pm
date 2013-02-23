package Observer::Controller::Auth;
use Moose;
use namespace::autoclean;

use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Observer::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->user_exists ) {
        $c->res->redirect( $c->uri_for('/') );
        return
    }

    if ( $c->authenticate({
                username => $c->req->param("username"),
                password => $c->req->param("password"),
            }) ) {

        $c->stash->{redirect} = $c->uri_for_action('root', { preventCache => $c->req->params->{"request.preventCache"} })->as_string;
    } else {
        $c->stash->{error} = $c->loc("Bad username or password!");
    }

    $c->detach( $c->view('JSON') );
}

=head2 logout

=cut

sub logout : Local {
    my ( $self, $c ) = @_;

    $c->res->redirect( $c->uri_for('/') );
    $c->logout;
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
