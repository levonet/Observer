package Observer::Controller::Device::View;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Observer::Controller::Device::View - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub view : Chained('/') PathPart('device/view') CaptureArgs(1) {
    my ( $self, $c, $dev_id ) = @_;

    $c->stash->{current_view} = 'HTML';
    $c->stash->{dev_id} = $dev_id;

    $c->log->debug("view");
}

sub root : Chained('view') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
}

sub info : Chained('view') PathPart('info') Args(0) {
    my ( $self, $c ) = @_;

    my $row_info = $c->model('DB::Device')->info($c->stash->{dev_id});
    return unless $c->check_area_role($row_info->area_host);

    $c->stash->{dev_info} = $row_info;
    $c->stash->{dev_status} = $c->model('DB::Device')->info_status($c->stash->{dev_id});
    $c->stash->{dev_error} = $c->model('DB::Errorlog')->find($row_info->err_id);
}

sub ports : Chained('view') PathPart('ports') Args(0) {
    my ( $self, $c ) = @_;

    return unless $c->check_area_role($c->model('DB::Device')->area($c->stash->{dev_id}));

    $c->stash->{dev_ports} = $c->model('DB::Port')->ports($c->stash->{dev_id});

}

sub edit : Chained('view') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    my $row_info = $c->model('DB::Device')->info($c->stash->{dev_id});
    return unless $c->check_area_role($row_info->area_host);

    $c->stash->{dev_info} = $row_info;
    $c->stash->{dev_status} = $c->model('DB::Device')->info_status($c->stash->{dev_id});
}

sub logs : Chained('view') PathPart('logs') Args(0) {
    my ( $self, $c ) = @_;

    return unless $c->check_area_role($c->model('DB::Device')->area($c->stash->{dev_id}));

    $c->stash->{dev_errors} = $c->model('DB::Errorlog')->search({
        DevId => $c->stash->{dev_id}
    }, {
        order_by    => [ { -desc => [qw/ me.EvTime /] } ],
    });
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
