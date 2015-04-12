package ResultsSystem::Results::Parser;

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

use ResultsSystem::Results::Result;
use ResultsSystem::Results::Set;

=head1 NAME

ResultsSystem::Results::Parser

=head1 VERSION

Version 3.01

=cut

our $VERSION = '3.01';

=head1 SYNOPSIS

Reads in a fixtures file with the format originally agreed with HCL back in 2002 or 2003. The
file will contain all the fixtures for a division for one season.

It creates a ResultsSystem::Results::Set object which contains the resulting Result objects.
This is stored in the attribute "fixtures".

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 ATTRIBUTES

=over

=item fixtures_file

Full name and path of the fixture file to be read.

=item fixtures_handler

ResultsSystem::Fixtures::Parser or compatible object.

=item results_file

Full name and path of theresultfile to be read.

=item results_handler

ResultsSystem::IO::XML or compatible object.

=item week_commencing

DateTime object.

=item results

ResultsSystem::Result::Set object.

=back

=cut

has fixtures_file    => ( 'is' => 'ro', 'required' => 1 );
has fixtures_handler => ( 'is' => 'ro', 'required' => 1 );

has results_file    => ( 'is' => 'ro', 'required' => 1 );
has results_handler => ( 'is' => 'ro', 'required' => 1 );

has week_commencing => ( 'is' => 'ro', 'required' => 1 );

has results => ( 'is' => 'rw', 'default' => sub { ResultsSystem::Results::Set->new(); } );

=head1 SUBROUTINES/METHODS

=head2 External Methods

=cut

=head3 new

Constructor. fixtures_file, fixtures_handler, results_file, results_handler
and week_commencing are required.

=cut

=head3 parse_file

Slurps in the source file using the results handler or the
fixtures handler.
 
If the results file exists, then that is used, otherwise the
fixtures handler is used. If the fixtures file doesn't exist
either then an exception is thrown.

Returns true or an exception.

=cut

sub parse_file {
  my ($self) = validate_pos( @_, 1 );

  if ( -e $self->results_file ) {
    $self->process_results();
  }
  elsif ( -e $self->fixtures_file ) {
    $self->process_fixtures();
  }
  else {
    die "Neither " . $self->results_file . " nor " . $self->fixtures_file . "exist.\n";
  }

  return 1;

}

=head3 parse_input

=cut

sub parse_input {
  my ( $self, $raw ) = validate_pos( @_, 1, { type => HASHREF } );
  my $i = 1;
  my @keys =
    qw/ result runs_scored wickets_lost comments bowling_pointd batting_points penalty_points /;

  my $parsed = { match => [] };
  while ( $raw->{ "home" . $i } ) {

    my $result = {};

    for my $k (@keys) {
      $result->{home_details}->{ "home_" . $k . $i } = $raw->{ "home_" . $k . $i };
    }

    for my $k (@keys) {
      $result->{away_details}->{ "away_" . $k . $i } = $raw->{ "away_" . $k . $i };
    }

    push @{ $parsed->{match} }, $result;

    $i++;

  }
  return $parsed;
}

=head2 Internal Methods

=cut

=head3 process_results

Populate $self->results with the result objects for the week.

=cut

sub process_results {
  my ($self) = validate_pos( @_, 1 );

  $self->results_handler->full_filename( $self->results_file );

  my $results = $self->results_handler->read();

  for my $r (@$results) {
    for my $k ( keys %$r ) {
      $r->{$k} = shift @{ $r->{$k} } if ref $r->{$k};
    }
    my $result = ResultsSystem::Result->new($r);
    $self->results->push($result);
  }

  return 1;

}

=head3 process_fixtures

Populate $self->results with result objects for the week which
have been created from Fixture objects.

=cut

sub process_fixtures {
  my ($self) = validate_pos( @_, 1 );

  $self->fixtures_handler->parse_file();

  my $iterator = $self->fixtures_handler->fixtures->iterator();

  my $local;

  $local = sub {
    my $it = shift;
    while ( my $f = $it->() ) {
      if ( ref($f) !~ m/Fixture$/ ) {
        $local->( $f->iterator );
      }
      else {
        if ( DateTime->compare( $f->week_commencing, $self->week_commencing ) == 0 ) {
          $self->results->push(
            ResultsSystem::Results::Result->new( home => $f->home, away => $f->away ) );
        }
      }
    }
  };

  $local->($iterator);

  return 1;
}

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-resultssystem-fixturelist at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ResultsSystem-Results::Parser>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ResultsSystem::Results::Parser


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ResultsSystem-Results::Parser>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ResultsSystem-Results::Parser>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ResultsSystem-Results::Parser>

=item * Search CPAN

L<http://search.cpan.org/dist/ResultsSystem-Results::Parser/>

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

# End of ResultsSystem::Results::Parser
