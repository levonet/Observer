package Observer;
use Moose;
use namespace::autoclean;

use utf8;
use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple

    I18N
    Unicode

    Authentication
    Authorization::Roles

    Session
    Session::Store::FastMmap
    Session::State::Cookie

    Observer::Settings
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in observer.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Observer',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    session => { flash_to_stash => 1 },
    default_view => 'HTMLWrap',
    'View::HTMLWrap' => {
        ENCODING => 'UTF-8',
    },
    'View::HTML' => {
        ENCODING => 'UTF-8',
    },
);

# Start the application
__PACKAGE__->setup();

sub uri_for_static {
    my ( $self, $asset ) = @_;
    return ( $self->config->{static_url_path} || '/static/' ) . $asset;
}

sub enc {
    my ( $self, $str ) = @_;

    utf8::decode($str);
    return $str;
}

sub in_array {
    my ( $self, $tmpArr, $search) = @_;

    return 0 unless ref($tmpArr) eq 'ARRAY';
    return scalar(grep { $_ eq $search } @{$tmpArr});
}

sub check_area_role {
    my ( $self, $area ) = @_;

    return 0 unless defined $area;
    return 0 unless $self->user_exists;
    unless ($self->check_user_roles(qw/ all_areas /)) {
        eval {
            my $areas = $self->config->{authentication}->{realms}->{$self->config->{authentication}->{default_realm}}->{store}->{users}->{$self->user->id}->{area};
            if (defined $areas) {
                if (ref $areas) {
                    return 0 unless $self->in_array($areas, $area);
                } else {
                    return 0 if $areas ne $area;
                }
            }
        };
        return 0 if $@;
    }
    return 1;
}

sub validate_input {
    my ( $self, $param) = @_;

    return undef unless defined $param;

    $param =~ s/[\n\t,]+/ /g;
    $param =~ s/^\s+|\s+$//g;

    return $param ne '' ? $param : undef;
}

=head1 NAME

Observer - Catalyst based application

=head1 SYNOPSIS

    script/observer_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Observer::Controller::Root>, L<Catalyst>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
