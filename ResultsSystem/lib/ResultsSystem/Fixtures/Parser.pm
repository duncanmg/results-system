package ResultsSystem::Fixtures::Parser;

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

use ResultsSystem::Fixtures::Fixture;
use ResultsSystem::Fixtures::Set;

=head1 NAME

ResultsSystem::Fixtures::Parser

=head1 VERSION

Version 3.01

=cut

our $VERSION = '3.01';

=head1 SYNOPSIS

Reads in a fixtures file with the format originally agreed with HCL back in 2002 or 2003. The
file will contain all the fixtures for a division for one season.

It creates a ResultsSystem::Fixtures::Set object which contains the resulting Fixture objects.
This is stored in the attribute "fixtures".

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 ATTRIBUTES

=over

=item source_file

Full name and path of the file to be read.

=item csv

Text::CSV::XS or compatible CSV processing object.

=item datetime_natural

DateTime::Format::Natural or compatible date processing object.

=item fixtures

ResultsSystem::Fixtures::Set or compatible object. Defaults to
ResultsSystem::Fixtures::Set->new().

=item _week_pos

?

=back

=cut

has source_file => ( 'is' => 'ro', 'required' => 1 );
has csv => ( 'is' => 'rw' );
has datetime_natural => ( 'is' => 'rw' );

has fixtures => ( 'is' => 'rw', 'default' => sub { ResultsSystem::Fixtures::Set->new(); } );
has _week_pos => ( 'is' => 'rw' );

=head1 SUBROUTINES/METHODS

=head2 External Methods

=cut

=head3 new

Constructor. Only source_file is required, but it won't do much until
csv and datetime_natural are set.

=cut

=head3 parse_file

Slurps in the source file. It then splits the file into weeks assuming that the week delimiter
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

=head2 Internal Methods

=cut

=head3 parse_week

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
  my $fixtures = ResultsSystem::Fixtures::Set->new();
  foreach my $l (@$week) {

    $self->csv->parse($l) || croak "Unable to parse line. $l";
    my @fields = $self->csv->fields;

    $wc = $self->parse_date( \@fields ) if !$wc;
    next if !$wc;

    my ( $home, $away ) = $self->parse_teams( \@fields );
    next if !( $home && $away );

    $fixtures->push_element(
      ResultsSystem::Fixtures::Fixture->new(
        week_commencing => clone($wc),
        match_date      => clone($wc),
        home            => $home,
        away            => $away
      )
    );
  }
  $self->fixtures->push_element($fixtures) if ( $fixtures->count > 0 );
  return 1;
}

=head3 parse_date

my $datetime = $self->parse_date( $fields );

Accepts an array ref and attempts to turn the first element into a DateTime object.
Returns the DateTime object or undef.

=cut

sub parse_date {
  my ( $self, $fields ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my $field = shift @$fields;

  $field =~ s/[-\/]/ /g;

  $self->datetime_natural( DateTime::Format::Natural->new ) if !$self->datetime_natural;
  my $formatter = $self->datetime_natural;

  my $dt = $formatter->parse_datetime($field);
  return if !$formatter->success;
  return $dt;
}

=head3 parse_teams

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

=head1 Example CSV File

  05-May,,
  Broughton,Winterbourne & HPk II,
  Farley II,Centurions,
  OTs & Romsey IV,Michelmersh & T III,
  Wherwell II,Shrewton III,
  ==========,,
  12-May,,
  Farley II,Winterslow II,
  Michelmersh & T III,Wherwell II,
  Shrewton III,Broughton,
  Winterbourne & HPk II,Centurions,
  ==========,,
  19-May-2012,,
  Broughton,Michelmersh & T III,
  Centurions,Winterslow II,
  OTs & Romsey IV,Farley II,
  Winterbourne & HPk II,Shrewton III,,,,,
  ==========,,,,,,
  26-May,,,,,,
  Farley II,Wherwell II,,,,,
  Michelmersh & T III,Winterbourne & HPk II,,,,,
  Shrewton III,Centurions,,,,,
  Winterslow II,OTs & Romsey IV,,,,,
  ==========,,,,,,
  02-June,,,,,,
  Broughton,Farley II,,,,,
  Centurions,OTs & Romsey IV,,,,,
  Shrewton III,Michelmersh & T III,,,,,
  Wherwell II,Winterslow II,,,,,
  ==========,,,,,,
  09-Jun,,,,,,
  Farley II,Winterbourne & HPk II,,,,,
  Michelmersh & T III,Centurions
  OTs & Romsey IV,Wherwell II
  Winterslow II,Broughton
  ==========,
  16/Jun,
  Broughton,OTs & Romsey IV
  Centurions,Wherwell II
  Shrewton III,Farley II
  Winterbourne & HPk II,Winterslow II
  ==========,
  23-Jun,
  Farley II,Michelmersh & T III
  OTs & Romsey IV,Winterbourne & HPk II
  Wherwell II,Broughton
  Winterslow II,Shrewton III
  ==========,

=cut

=head1 Example Stringified Fixtures Set

  ResultsSystem::Fixtures::Set with 18 elements
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: Broughton away: Winterbourne & HPk II
      week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: Farley II away: Centurions
      week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: OTs & Romsey IV away: Michelmersh & T III
      week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: Wherwell II away: Shrewton III
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 12 May 2015 match_date: Tuesday 12 May 2015 home: Farley II away: Winterslow II
      week_commencing: Tuesday 12 May 2015 match_date: Tuesday 12 May 2015 home: Michelmersh & T III away: Wherwell II
      week_commencing: Tuesday 12 May 2015 match_date: Tuesday 12 May 2015 home: Shrewton III away: Broughton
      week_commencing: Tuesday 12 May 2015 match_date: Tuesday 12 May 2015 home: Winterbourne & HPk II away: Centurions
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Saturday 19 May 2012 match_date: Saturday 19 May 2012 home: Broughton away: Michelmersh & T III
      week_commencing: Saturday 19 May 2012 match_date: Saturday 19 May 2012 home: Centurions away: Winterslow II
      week_commencing: Saturday 19 May 2012 match_date: Saturday 19 May 2012 home: OTs & Romsey IV away: Farley II
      week_commencing: Saturday 19 May 2012 match_date: Saturday 19 May 2012 home: Winterbourne & HPk II away: Shrewton III
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 26 May 2015 match_date: Tuesday 26 May 2015 home: Farley II away: Wherwell II
      week_commencing: Tuesday 26 May 2015 match_date: Tuesday 26 May 2015 home: Michelmersh & T III away: Winterbourne & HPk II
      week_commencing: Tuesday 26 May 2015 match_date: Tuesday 26 May 2015 home: Shrewton III away: Centurions
      week_commencing: Tuesday 26 May 2015 match_date: Tuesday 26 May 2015 home: Winterslow II away: OTs & Romsey IV
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 2 June 2015 match_date: Tuesday 2 June 2015 home: Broughton away: Farley II
      week_commencing: Tuesday 2 June 2015 match_date: Tuesday 2 June 2015 home: Centurions away: OTs & Romsey IV
      week_commencing: Tuesday 2 June 2015 match_date: Tuesday 2 June 2015 home: Shrewton III away: Michelmersh & T III
      week_commencing: Tuesday 2 June 2015 match_date: Tuesday 2 June 2015 home: Wherwell II away: Winterslow II
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 9 June 2015 match_date: Tuesday 9 June 2015 home: Farley II away: Winterbourne & HPk II
      week_commencing: Tuesday 9 June 2015 match_date: Tuesday 9 June 2015 home: Michelmersh & T III away: Centurions
      week_commencing: Tuesday 9 June 2015 match_date: Tuesday 9 June 2015 home: OTs & Romsey IV away: Wherwell II
      week_commencing: Tuesday 9 June 2015 match_date: Tuesday 9 June 2015 home: Winterslow II away: Broughton
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 16 June 2015 match_date: Tuesday 16 June 2015 home: Broughton away: OTs & Romsey IV
      week_commencing: Tuesday 16 June 2015 match_date: Tuesday 16 June 2015 home: Centurions away: Wherwell II
      week_commencing: Tuesday 16 June 2015 match_date: Tuesday 16 June 2015 home: Shrewton III away: Farley II
      week_commencing: Tuesday 16 June 2015 match_date: Tuesday 16 June 2015 home: Winterbourne & HPk II away: Winterslow II
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 23 June 2015 match_date: Tuesday 23 June 2015 home: Farley II away: Michelmersh & T III
      week_commencing: Tuesday 23 June 2015 match_date: Tuesday 23 June 2015 home: OTs & Romsey IV away: Winterbourne & HPk II
      week_commencing: Tuesday 23 June 2015 match_date: Tuesday 23 June 2015 home: Wherwell II away: Broughton
      week_commencing: Tuesday 23 June 2015 match_date: Tuesday 23 June 2015 home: Winterslow II away: Shrewton III
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 30 June 2015 match_date: Tuesday 30 June 2015 home: Broughton away: Centurions
      week_commencing: Tuesday 30 June 2015 match_date: Tuesday 30 June 2015 home: OTs & Romsey IV away: Shrewton III
      week_commencing: Tuesday 30 June 2015 match_date: Tuesday 30 June 2015 home: Wherwell II away: Winterbourne & HPk II
      week_commencing: Tuesday 30 June 2015 match_date: Tuesday 30 June 2015 home: Winterslow II away: Michelmersh & T III
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 7 July 2015 match_date: Tuesday 7 July 2015 home: Centurions away: Farley II
      week_commencing: Tuesday 7 July 2015 match_date: Tuesday 7 July 2015 home: Michelmersh & T III away: OTs & Romsey IV
      week_commencing: Tuesday 7 July 2015 match_date: Tuesday 7 July 2015 home: Shrewton III away: Wherwell II
      week_commencing: Tuesday 7 July 2015 match_date: Tuesday 7 July 2015 home: Winterbourne & HPk II away: Broughton
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 14 July 2015 match_date: Tuesday 14 July 2015 home: Broughton away: Shrewton III
      week_commencing: Tuesday 14 July 2015 match_date: Tuesday 14 July 2015 home: Centurions away: Winterbourne & HPk II
      week_commencing: Tuesday 14 July 2015 match_date: Tuesday 14 July 2015 home: Wherwell II away: Michelmersh & T III
      week_commencing: Tuesday 14 July 2015 match_date: Tuesday 14 July 2015 home: Winterslow II away: Farley II
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 21 July 2015 match_date: Tuesday 21 July 2015 home: Farley II away: OTs & Romsey IV
      week_commencing: Tuesday 21 July 2015 match_date: Tuesday 21 July 2015 home: Michelmersh & T III away: Broughton
      week_commencing: Tuesday 21 July 2015 match_date: Tuesday 21 July 2015 home: Shrewton III away: Winterbourne & HPk II
      week_commencing: Tuesday 21 July 2015 match_date: Tuesday 21 July 2015 home: Winterslow II away: Centurions
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 28 July 2015 match_date: Tuesday 28 July 2015 home: Centurions away: Shrewton III
      week_commencing: Tuesday 28 July 2015 match_date: Tuesday 28 July 2015 home: OTs & Romsey IV away: Winterslow II
      week_commencing: Tuesday 28 July 2015 match_date: Tuesday 28 July 2015 home: Wherwell II away: Farley II
      week_commencing: Tuesday 28 July 2015 match_date: Tuesday 28 July 2015 home: Winterbourne & HPk II away: Michelmersh & T III
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 4 August 2015 match_date: Tuesday 4 August 2015 home: Farley II away: Broughton
      week_commencing: Tuesday 4 August 2015 match_date: Tuesday 4 August 2015 home: Michelmersh & T III away: Shrewton III
      week_commencing: Tuesday 4 August 2015 match_date: Tuesday 4 August 2015 home: OTs & Romsey IV away: Centurions
      week_commencing: Tuesday 4 August 2015 match_date: Tuesday 4 August 2015 home: Winterslow II away: Wherwell II
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 11 August 2015 match_date: Tuesday 11 August 2015 home: Broughton away: Winterslow II
      week_commencing: Tuesday 11 August 2015 match_date: Tuesday 11 August 2015 home: Centurions away: Michelmersh & T III
      week_commencing: Tuesday 11 August 2015 match_date: Tuesday 11 August 2015 home: Wherwell II away: OTs & Romsey IV
      week_commencing: Tuesday 11 August 2015 match_date: Tuesday 11 August 2015 home: Winterbourne & HPk II away: Farley II
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 18 August 2015 match_date: Tuesday 18 August 2015 home: Farley II away: Shrewton III
      week_commencing: Tuesday 18 August 2015 match_date: Tuesday 18 August 2015 home: OTs & Romsey IV away: Broughton
      week_commencing: Tuesday 18 August 2015 match_date: Tuesday 18 August 2015 home: Wherwell II away: Centurions
      week_commencing: Tuesday 18 August 2015 match_date: Tuesday 18 August 2015 home: Winterslow II away: Winterbourne & HPk II
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 25 August 2015 match_date: Tuesday 25 August 2015 home: Broughton away: Wherwell II
      week_commencing: Tuesday 25 August 2015 match_date: Tuesday 25 August 2015 home: Michelmersh & T III away: Farley II
      week_commencing: Tuesday 25 August 2015 match_date: Tuesday 25 August 2015 home: Shrewton III away: Winterslow II
      week_commencing: Tuesday 25 August 2015 match_date: Tuesday 25 August 2015 home: Winterbourne & HPk II away: OTs & Romsey IV
    ResultsSystem::Fixtures::Set with 4 elements
      week_commencing: Tuesday 1 September 2015 match_date: Tuesday 1 September 2015 home: Centurions away: Broughton
      week_commencing: Tuesday 1 September 2015 match_date: Tuesday 1 September 2015 home: Michelmersh & T III away: Winterslow II
      week_commencing: Tuesday 1 September 2015 match_date: Tuesday 1 September 2015 home: Shrewton III away: OTs & Romsey IV
      week_commencing: Tuesday 1 September 2015 match_date: Tuesday 1 September 2015 home: Winterbourne & HPk II away: Wherwell II
  [debug] week 1 is ResultsSystem::Fixtures::Set with 4 elements
    week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: Broughton away: Winterbourne & HPk II
    week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: Farley II away: Centurions
    week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: OTs & Romsey IV away: Michelmersh & T III
    week_commencing: Tuesday 5 May 2015 match_date: Tuesday 5 May 2015 home: Wherwell II away: Shrewton III

=cut

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-resultssystem-fixturelist at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ResultsSystem-Fixtures::Parser>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ResultsSystem::Fixtures::Parser


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ResultsSystem-Fixtures::Parser>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ResultsSystem-Fixtures::Parser>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ResultsSystem-Fixtures::Parser>

=item * Search CPAN

L<http://search.cpan.org/dist/ResultsSystem-Fixtures::Parser/>

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

# End of ResultsSystem::Fixtures::Parser
