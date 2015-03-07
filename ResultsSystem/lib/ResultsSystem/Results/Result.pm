package ResultsSystem::Results::Result;

use 5.008;
use strict;
use warnings;

use Moo;

=head1 NAME

ResultsSystem::Results::Result.

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

=head2 General

=over

=item week_commencing

=item match_date

=item played

=cut

=head2 Home

=over

=item home

=item home_result

=item home_runs_scored

=item home_wickets_lost

=item home_comments

=item home_batting_points

=item home_bowling_points

=item home_total_points

=cut

=head2 Away

=over

=item away

=item away_result

=item away_runs_scored

=item away_wickets_lost

=item away_comments

=item away_batting_points

=item away_bowling_points

=item away_total_points

=cut




has 'week_commencing' => ( 'is' => 'rw', required => 1 );
has 'match_date'      => ( 'is' => 'rw' );
has 'played'          => ( 'is' => 'rw' );

has 'home'                => ( 'is' => 'rw' );
has 'home_result'         => ( 'is' => 'rw' );
has 'home_runs_scored'    => ( 'is' => 'rw' );
has 'home_wickets_lost'   => ( 'is' => 'rw' );
has 'home_comments'       => ( 'is' => 'rw' );
has 'home_batting_points' => ( 'is' => 'rw' );
has 'home_bowling_points' => ( 'is' => 'rw' );
has 'home_total_points'   => ( 'is' => 'rw' );

has 'away'                => ( 'is' => 'rw' );
has 'away_result'         => ( 'is' => 'rw' );
has 'away_runs_scored'    => ( 'is' => 'rw' );
has 'away_wickets_lost'   => ( 'is' => 'rw' );
has 'away_comments'       => ( 'is' => 'rw' );
has 'away_batting_points' => ( 'is' => 'rw' );
has 'away_bowling_points' => ( 'is' => 'rw' );
has 'away_total_points'   => ( 'is' => 'rw' );

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
  return if !$d;
  return sprintf( "%s %d %s %d", $d->day_name, $d->day, $d->month_name, $d->year );
}

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-resultssystem-fixture at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ResultsSystem-Results::Result>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ResultsSystem::Results::Result


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ResultsSystem-Results::Result>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ResultsSystem-Results::Result>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ResultsSystem-Results::Result>

=item * Search CPAN

L<http://search.cpan.org/dist/ResultsSystem-Results::Result/>

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

1;    # End of ResultsSystem::Results::Result
