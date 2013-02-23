package Observer::Controller::Device::Navbar;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Observer::Controller::Device::Navbar - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub navbar : Chained('/') PathPart('device/navbar') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current_view} = 'HTML';

    $c->log->debug("navbar");
}

sub areas : Chained('navbar') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("navbar0");

    return unless $c->user_exists;

    if ($c->check_user_roles(qw/ all_areas /)) {
        $c->stash->{areas} = $c->model('DB::Device')->areas;
    } else {
        eval {
            my $area = $c->config->{authentication}->{realms}->{$c->config->{authentication}->{default_realm}}->{store}->{users}->{$c->user->id}->{area};
            if (defined $area) {
                my $cond = {};
                if (ref $area) {
                    foreach (@{$area}) { push @{$cond->{-or}}, { AreaHost => $_ }; }
                } else {
                    $cond->{AreaHost} = $area;
                }
                $c->stash->{areas} = $c->model('DB::Device')->areas($cond);
            }
        };
    }
}

sub hosts : Chained('navbar') PathPart('') Args(1) {
    my ( $self, $c, $area ) = @_;

    $c->log->debug("navbar $area");

    return unless $c->check_area_role($area);

    $c->stash->{hosts} = $c->model('DB::Device')->hosts($area, $c->config->{'update_device_timeout'}, $c->config->{'idle_timeout'});
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
