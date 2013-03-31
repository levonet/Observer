package Catalyst::Plugin::Observer::Settings;

use Moose;
use namespace::autoclean;

use JSON;
use MRO::Compat;
use Catalyst::Exception;
use Carp;

our $VERSION = "0.01";

has _settings_keylist => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    #TODO: вынести список в конфиг
    default => sub {[
        'device/area',
        'device/viewmac',
        'test/bool',
    ]},
);

has _settings_store  => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
        _settings_store_set     => 'set',
        _settings_store_clear   => 'clear',
        _settings_store_elements=> 'elements',
    },
);

sub setup {
    my $c = shift;

    $c->maybe::next::method(@_);

    unless ($c->isa("Catalyst::Plugin::Session")) {
        my $err = "The Settings plugin requires Session plugin to be used as well.";
        $c->log->fatal($err);
        Catalyst::Exception->throw($err);
    }

    return $c;
}

# setter
sub settings {
    my $c = shift;

    if (@_) {
        my $new_values = @_ > 1 ? { @_ } : $_[0];
        croak('session takes a hash or hashref') unless ref $new_values;
        for my $key (keys %$new_values) {
            if (scalar(grep { $_ eq $key } @{$c->_settings_keylist})) {
                if (!defined $new_values->{$key}) {
                    $c->session->{$key} = JSON::null;
                } elsif (lc($new_values->{$key}) eq 'true') {
                    $c->session->{$key} = JSON::true;
                } elsif (lc($new_values->{$key}) eq 'false') {
                    $c->session->{$key} = JSON::false;
                } else {
                    $c->session->{$key} = $new_values->{$key};
                }
            } else {
                croak('settings takes a hash with determined keys');
            }
        }
    }

    return $c->session;
}

# getter
sub settings_json {
    my $c = shift;

    $c->_settings_store_clear;
    foreach (@{$c->_settings_keylist}) {
        $c->_settings_store_set($_, $c->session->{$_})
            if (exists $c->session->{$_});
    }

    my $json = JSON->new->allow_nonref;
    return $json->encode({$c->_settings_store_elements});
}

=head1 NAME

Catalyst::Plugin::Observer::Settings

=head1 DESCRIPTION

Catalyst Plugin.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
