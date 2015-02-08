package ResultsSystem::Fixtures::Fixture;

use 5.008;
use strict;
use warnings;

use Moo;

=head1 NAME

ResultsSystem::Fixtures::Fixture.

=head1 VERSION

Version 3.01

=cut

our $VERSION = '3.01';

=head1 SYNOPSIS

Object which holds the week commencing, match date, the name of the home team and
the name of the away team for a fixture and stringifies as described below.

=head1 EXPORT

Nothing

=head1 ATTRIBUTES

=over

=item week_commencing

DateTime object. Required. Read only.

=item match_date

DateTime object. Read only.

=item home

The name of the home team. String. Read only.

=item away

The name of the away team. String. Read only.

=back

=cut

has 'week_commencing' => ( 'is' => 'ro', required => 1 );
has 'match_date'      => ( 'is' => 'ro' );
has 'home'            => ( 'is' => 'ro' );
has 'away'            => ( 'is' => 'ro' );

=head1 SUBROUTINES/METHODS

=cut

=head2 stringify

Stringifies the object to the form:

week_commencing: Monday 2 June 2015 match_date: Tuesday 3 June 2015 home: England away: Australia

=cut

use overload '""' => 'stringify';

sub stringify {
  my ($self) = @_;
  my ( $wc, $md );
  return
      'week_commencing: '
    . ( $self->_format_date( $self->week_commencing ) || "" )
    . ' match_date: '
    . ( $self->_format_date( $self->match_date ) || "" )
    . ' home: '
    . ( $self->home || "" )
    . ' away: '
    . ( $self->away || "" );
}

=head2 _format_date

Accepts a DateTime object and return a string of the form Monday 2 June 2015.

=cut

sub _format_date {
  my ( $self, $d ) = @_;
  return sprintf( "%s %d %s %d", $d->day_name, $d->day, $d->month_name, $d->year );
}

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-resultssystem-fixture at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ResultsSystem-Fixtures::Fixture>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ResultsSystem::Fixtures::Fixture


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ResultsSystem-Fixtures::Fixture>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ResultsSystem-Fixtures::Fixture>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ResultsSystem-Fixtures::Fixture>

=item * Search CPAN

L<http://search.cpan.org/dist/ResultsSystem-Fixtures::Fixture/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Duncan Garland.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of ResultsSystem::Fixtures::Fixture
