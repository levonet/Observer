package Observer::View::HTMLWrap;
use Moose;
use namespace::autoclean;

use utf8;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    INCLUDE_PATH => [
        Observer->path_to('root', 'base'),
    ],
    WRAPPER => 'wrapper.tt',
);

=head1 NAME

Observer::View::HTMLWrap - TT View for Observer

=head1 DESCRIPTION

TT View for Observer.

=head1 SEE ALSO

L<Observer>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
