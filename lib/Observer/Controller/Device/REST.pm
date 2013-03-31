package Observer::Controller::Device::REST;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

Observer::Controller::Device::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub rest : Chained('/') PathPart('device/rest') CaptureArgs(0) { my ( $self, $c ) = @_; }

sub hostitem_id : Chained('rest') PathPart('hostitem') Args(1) ActionClass('REST') {}

sub hostitem_id_PUT {
    my ( $self, $c, $id) = @_;
    $c->log->debug("edit::PUT ".$id);

    $c->session->{current_area} = $c->model('DB::Device')->area($id);
    unless ($c->session->{current_area}) {
        $self->status_not_found( $c, message => $c->loc("Cannot find device") );
        return;
    }

    # rules
    unless ($c->check_area_role($c->session->{current_area})) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    $c->session->{current_dev} = $id;
    $c->session->{selected_devs}->{$id} = 1;

    $self->status_ok( $c, entity => { status => 'set' } );
}

sub hostitem_id_DELETE {
    my ( $self, $c, $id) = @_;
    $c->log->debug("edit::DELETE ".$id);

    my $area = $c->model('DB::Device')->area($id);
    unless ($area) {
        $self->status_not_found( $c, message => $c->loc("Cannot find device") );
        return;
    }

    # rules
    unless ($c->check_area_role($area)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    delete $c->session->{selected_devs}->{$id};
    $c->session->{current_dev} = undef if $c->session->{current_dev} == $id;

    $self->status_ok( $c, entity => { status => 'del' } );
}

sub macs_id : Chained('rest') PathPart('macs') Args(1) ActionClass('REST') {}

sub macs_id_GET {
    my ( $self, $c, $id) = @_;

    # rules
    my $area = $c->model('DB::Device')->area($id);
    unless ($area) {
        $self->status_not_found( $c, message => $c->loc("Cannot find device") );
        return;
    }
    unless ($c->check_area_role($area)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    $c->log->debug("edit::GET ".$id);
    my $rc = $c->model('DB::Macaddress')->view($id);

    my %result;
    foreach my $row ($rc->all) {
        push(@{$result{$row->get_column('Port')}}, {
            mac     => $row->mac,
            service => $row->service,
            updtime => "'".$row->upd_time."'",
            online  => $row->get_column('online'),
        });
    }

    $self->status_ok( $c, entity => { devId => $id, macs => { %result } } );

}

sub find : Chained('rest') PathPart('find') Args(0) ActionClass('REST') {}

sub find_GET {
    my ( $self, $c ) = @_;

    $c->log->debug("REST::find_GET ");

    unless (defined $c->req->param("findAreaHost")) {           # возвращаем пустую строчку,
        $self->status_ok( $c, entity => [] );                   # если это не ползовательский запрос
        return;
    }

    # validate
    my ($area_host, $src_host, $mac);
    unless ( defined($area_host = $c->validate_input($c->req->param("findAreaHost"))) ) {
        $self->status_bad_request( $c, message => $c->loc("Please complete the required field '[_1]'.", $c->loc('Area:')) );
        return;
    }

    # rules
    unless ($c->check_area_role($area_host)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    $src_host = $c->req->param("findSrcHost");                  # for rlike
    $src_host =~ s/\'/\"/g;
    $src_host = undef if $src_host eq '';
    $mac = $c->validate_input($c->req->param("findMAC"));       # for eq
    $mac =~ s/\'/\"/g if defined $mac;
#FIXIT [0-9a-f][\s:.-][0-9a-f] => \d\d - потому что передаем в rlike а там может быть .*
    $mac =~ s/[\s:-]//g if defined $mac;

    unless (defined $src_host || defined $mac) {
        $self->status_ok( $c, entity => [] );
        return;
    }

    my @result;
    if (defined $mac && $mac) {
        my $rc = $c->model('DB::Macaddress')->findBy($area_host, $src_host, lc($mac));

        foreach my $row ($rc->all) {
            $c->log->debug($row->dev_id);
            push(@result, {
                id          => $row->dev_id,
                AreaHost    => $row->get_column("AreaHost"),
                SrcHost     => $row->get_column("SrcHost"),
                IfStatus    => $row->get_column("IfStatus"),
                IfName      => $row->get_column("IfName"),
                Service     => $row->service,
                MAC         => $row->mac,
                UpdTime     => "'".$row->upd_time."'",
            });
        }
    } else {
        my $rc = $c->model('DB::Device')->findBy($area_host, $src_host);

        foreach my $row ($rc->all) {
            $c->log->debug($row->dev_id);
            push(@result, {
                id          => $row->dev_id,
                AreaHost    => $row->area_host,
                SrcHost     => $row->src_host,
                IfStatus    => '',
                IfName      => '',
                Service     => '',
                MAC         => '',
                UpdTime     => "'".$row->upd_time."'",
            });
        }
    }

    $self->status_ok( $c, entity => [ @result ] );

}

sub adddev : Chained('rest') PathPart('adddev') Args(0) ActionClass('REST') {}

sub adddev_POST {
    my ( $self, $c ) = @_;

    $c->log->debug("REST::adddev_POST ");

    # rules
    unless ($c->check_user_roles(qw/ edit /)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    my ($area_host, $community, $src_hosts);

    # validate
    unless ( defined($area_host = $c->validate_input($c->req->data->{'area_host'})) ) {
        $self->status_bad_request( $c, message => $c->loc("Please complete the required field '[_1]'.", $c->loc('Area:')) );
        return;
    }
    unless ( defined($community = $c->validate_input($c->req->data->{'community'})) ) {
        $self->status_bad_request( $c, message => $c->loc("Please complete the required field '[_1]'.", $c->loc('Community:')) );
        return;
    }
    unless ( defined($src_hosts = $c->validate_input($c->req->data->{'src_hosts'})) ) {
        $self->status_bad_request( $c, message => $c->loc("Please complete the required field '[_1]'.", $c->loc('Hosts:')) );
        return;
    }

    # rules
    unless ($c->check_area_role($area_host)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    foreach (split /\s+/, $src_hosts) {
        $c->log->debug('HOST: '.$_);

#TODO: проверка, если такой хост в данной ареа существует и не блокирован, то пропускаем добавление,
#      а в морду передаем список не добавленных хостов, который выводится в диалоге

        my $rs = $c->model('DB::Device')->create({
            AreaHost       => $area_host,
            SrcHost        => $_,
            Community      => $community,
            Status         => $c->model('DB::Device')->status_mask({
                                    USER_NEWDEV => 1,
                                    WALK_INWORK => 0,
                                    WRITE_MODE => defined($c->req->data->{'status_write_mode'}[0])
                                 }),
            UpdTime        => \"now()", #"
        });

        unless (defined $rs) {
            $self->status_bad_request( $c, message => $c->loc('Device [_1] does not added', $_) );
            return;
        }
    }
    $self->status_accepted( $c, entity => { status => 1 } );
}

sub edit_id : Chained('rest') PathPart('edit') Args(1) ActionClass('REST') {}

sub edit_id_POST {
    my ( $self, $c, $id ) = @_;

    # rules
    unless ($c->check_user_roles(qw/ edit /)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    my $area_host = $c->validate_input($c->req->data->{'area_host'});
    my $community = $c->validate_input($c->req->data->{'community'});
    my $src_host  = $c->validate_input($c->req->data->{'src_host'});

    # validate
    my $cond = {};
    $cond->{AreaHost} = $area_host if defined $area_host;
    $cond->{Community} = $community if defined $community;
    $cond->{SrcHost} = $src_host if defined $src_host;

    # rules
    if (defined $area_host && ! $c->check_area_role($area_host)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    my $row = $c->model('DB::Device')->find($id);
    unless ($row) {
        $self->status_not_found( $c, message => $c->loc("Cannot find device") );
        return;
    }
    unless ($c->check_area_role($row->area_host)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    $cond->{Status} = $c->model('DB::Device')->status_mask({ WRITE_MODE => defined($c->req->data->{'status_write_mode'}[0]) }, $row->status);
    $cond->{UpdTime} = \"now()"; #"

    $row->update($cond);

    unless (defined $row) {
        $self->status_bad_request( $c, message => $c->loc('Device [_1] does not update', $_) );
        return;
    }

    $self->status_accepted( $c, entity => { status => 1 } );
}

sub edit_id_DELETE {
    my ( $self, $c, $id) = @_;

    # rules
    unless ($c->check_user_roles(qw/ delete /)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    my $area = $c->model('DB::Device')->area($id);
    unless ($area) {
        $self->status_not_found( $c, message => $c->loc("Cannot find device") );
        return;
    }
    unless ($c->check_area_role($area)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    $c->model('DB::Device')->delete_dev($id);

    $self->status_accepted( $c, entity => { status => 1, devId => $id } );
}

sub status_id : Chained('rest') PathPart('status') Args(1) ActionClass('REST') {}

sub status_id_POST {
    my ( $self, $c, $id) = @_;

    # rules
    unless ($c->check_user_roles(qw/ edit /)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    my $row = $c->model('DB::Device')->find($id);
    unless ($row) {
        $self->status_not_found( $c, message => $c->loc("Cannot find device") );
        return;
    }
    unless ($c->check_area_role($row->area_host)) {
        $self->status_forbidden( $c, message => $c->loc("Access denied") );
        return;
    }

    my $status = {};
    foreach (qw/ VIEW_LOCK WALK_LOCK WALK_INWORK USER_NEWDEV USER_UPDDEV WALK_ERR_LOCK USER_ERR_LOCK /) {
        if (exists $c->req->data->{$_}) {
             $status->{$_} =  defined($c->req->data->{$_}[0]) || 0;
        }
    }

    $row->update({
        Status  => $c->model('DB::Device')->status_mask($status, $row->status),
        UpdTime => \'now()', #'
    });

    $self->status_accepted( $c, entity => { status => 1 } );
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
