package ResultsSystem::FixtureList;

use 5.008;
use strict;
use warnings;

use Moo;
use DateTime;
use Text::CSV;
use File::Slurp qw/ slurp/;
use List::MoreUtils qw/part/;
use Params::Validate qw/:all/;
use Carp;
use DateTime::Format::Natural;
use Clone qw/ clone /;

use ResultsSystem::Fixture;

=head1 NAME

ResultsSystem::FixtureList - The great new ResultsSystem::FixtureList!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '3.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use ResultsSystem::FixtureList;

    my $foo = ResultsSystem::FixtureList->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 ATTRIBUTES

=over

=item source_file

=item csv

=item datetime_natural

=item fixtures_by_week

=back

=cut

has source_file => ( 'is' => 'ro', 'required' => 1 );
has csv => ( 'is' => 'rw' );
has datetime_natural => ( 'is' => 'rw' );

has _fixtures_by_week => ( 'is' => 'rw' );
has _week_pos         => ( 'is' => 'rw' );

=head1 SUBROUTINES/METHODS

=head2 parse_file

Slurps in the source file. It then spilts the file into weeks assuming that the week delimiter
is the line with at least 6 "=" characters in it. eg "=====".

Each week is then passed to parse_week for further processing.

Returns true or an exception.

=cut

sub parse_file {
  my ($self) = validate_pos( @_, 1 );

  $self->csv( Text::CSV->new( { binary => 1 } ) ) if !$self->csv;

  my @lines = slurp( $self->source_file );

  my $i = 0;
  my @weeks = part { $i++ if $_ =~ m/^={6}/; $i; } @lines;

  foreach my $w (@weeks) {
    $self->parse_week($w);
  }
  return 1;

}

=head2 parse_week

Accepts a week of fixtures as an array ref and parses them. 

Each element of the array reference must be a comma-separated list of fields. Each line
must be either a date, or a home team and an away team.

eg

27-Jun-2014
Purbrook, Waterlooville
England, Australia

The line is parsed and a set of Fixture objects for the week are appended to the fixtures_by_week
attribute.

Lines which do not parse are skipped.

Returns 1 or an exception.

=cut

sub parse_week {
  my ( $self, $week ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my $wc;
  my $fixtures = [];
  foreach my $l (@$week) {

    $self->csv->parse($l) || croak "Unable to parse line. $l";
    my @fields = $self->csv->fields;

    $wc = $self->parse_date( \@fields ) if !$wc;
    next if !$wc;

    my ( $home, $away ) = $self->parse_teams( \@fields );
    next if !( $home && $away );

    push @$fixtures,
      ResultsSystem::Fixture->new( week_commencing => clone($wc), home => $home, away => $away );
  }
  $self->_fixtures_by_week($fixtures);
  return 1;
}

=head2 parse_date

my $datetime = $self->parse_date( $fields );

Accepts an array ref and attempts to turn the first element into a DateTime object.
Returns the DateTime object or undef.

=cut

sub parse_date {
  my ( $self, $fields ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my $field = shift @$fields;

  $field =~ s/-/ /g;

  $self->datetime_natural( DateTime::Format::Natural->new ) if !$self->datetime_natural;
  my $formatter = $self->datetime_natural;

  my $dt = $formatter->parse_datetime($field);
  return if !$formatter->success;
  return $dt;
}

=head2 parse_teams

my ( home, $away ) = $self->parse_teams( $fields );

Returns  the home and away teams if the first two fields of the array ref each contain
at least one word character and neither contains the characters <,>,! or |.

If either home or away is undef then the parse has failed.

=cut

sub parse_teams {
  my ( $self, $fields ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my ( $home, $away ) =
    grep { ( $_ || "" ) !~ m/[<>!|]/ && ( $_ || "" ) =~ m/\w/ } @$fields[ 0 .. 1 ];
  return ( $home, $away );
}

=head2 week_iterator

=cut

sub week_iterator {
  my ($self) = validate_pos( @_, 1 );
  return $self->_iterator( $self->_fixtures_by_week );
}

=head2 fixture_iterator

=cut

sub fixture_iterator {
  my ( $self, $week ) = validate_pos( @_, 1, 1 );
  return $self->_iterator($week);
}

=head2 _iterator

=cut

sub _iterator {
  my ( $self, $elements ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my $i = 0;
  return sub {
    if ( $i < @$elements ) { $i++; return $elements->[ $i - 1 ]; }
    else                   { return; }
  };
}

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-resultssystem-fixturelist at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ResultsSystem-FixtureList>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ResultsSystem::FixtureList


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ResultsSystem-FixtureList>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ResultsSystem-FixtureList>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ResultsSystem-FixtureList>

=item * Search CPAN

L<http://search.cpan.org/dist/ResultsSystem-FixtureList/>

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

1;

# End of ResultsSystem::FixtureList
