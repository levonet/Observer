package Observer::Controller::REST;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

Observer::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub settings : Local : ActionClass('REST') { }

#sub settings_GET {
#    my ( $self, $c ) = @_;
#
#    my %result;
#    foreach (keys %{$c->req->params}) {
#        $c->log->debug('PARAM: '.$_.' => '.$c->req->param($_));
#        $result{$_} = exists $c->session->{$_} ? $c->session->{$_} : $c->req->param($_);
#    }
#    $self->status_ok( $c, entity => { %result } );
#}

sub settings_POST {
    my ( $self, $c ) = @_;

    $c->settings($c->req->data);

    $self->status_ok( $c, entity => { status => 'set' } );
}

sub settings_DELETE {
    my ( $self, $c ) = @_;

    foreach (keys %{$c->req->params}) {
        $c->log->debug('PARAM: '.$_.' => '.$c->req->param($_));
        #delete $c->session->{$_};
    }
    #$self->status_not_found( $c, message => $c->loc("Cannot find") );
    $self->status_accepted( $c, entity => { status => 'del' } );
}

sub areas : Local : ActionClass('REST') { }

sub areas_GET {
    my ( $self, $c ) = @_;

    my $cond = {};

#    if () {
        $cond = undef;
#    }
    my $rs = $c->model('Device')->areas($cond);

    my $ret = [];
    while (my $row = $rs->next) {
        push(@{$ret}, { $row->get_columns });
    }

    $self->status_ok( $c, entity => $ret );
}

sub areas_POST {
    my ( $self, $c ) = @_;
$c->log->debug("rest::POST");

#    my $plants = undef;
#        $c->log->debug('DATS:'. $c->req->data);
#    foreach (@{$c->req->data}) {
#        $c->log->debug('DATS:'. $_);
        #TODO: Add check from DB
#        #$plants->{$_} = 1 if ( m/[\w]{4}/ );
#        push(@{$plants}, $_) if ( m/[\w]{4}/ );
#    }
#    $c->session->{plants} = $plants;

    foreach (keys %{$c->req->data}) {
        $c->log->debug('DATS: '.$_.' => '.$c->req->data->{$_});
    }

#    if (defined $plants) {
    if (1) {
        $self->status_ok( $c, entity => { status => 1 } );
    } else {
        $self->status_bad_request( $c, message => 'Plant does not select' );
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
