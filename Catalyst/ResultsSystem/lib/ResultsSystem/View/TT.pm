package ResultsSystem::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    WRAPPER => 'static/wrapper.tt'
);

=head1 NAME

ResultsSystem::View::TT - TT View for ResultsSystem

=head1 DESCRIPTION

TT View for ResultsSystem.

=head1 SEE ALSO

L<ResultsSystem>

=head1 AUTHOR

Duncan Garland,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
