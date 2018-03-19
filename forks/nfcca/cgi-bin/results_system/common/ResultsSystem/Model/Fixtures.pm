
=head1 NAME

ResultsSystem::Model::Fixtures

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This module reads and validates a fixtures csv file and loads it into an internal data structure. A Fixtures object
will inherit from Parent.pm.

The file should contain date lines and fixtures lines. Each date line should be followed by the fixture lines
for that date.

 21-Jun
 Purbrook, Waterlooville
 England, Australia
 28-Jun
 West Indies, South Africa
 Purbrook, England
 Australia, Waterlooville

There can also be an optional week separator consisting of a series of equals signs.

 21-Jun
 Purbrook, Waterlooville
 England, Australia
 ==========
 28-Jun
 West Indies, South Africa
 Purbrook, England
 Australia, Waterlooville
 ==========

Whitespace between the commas is allowed, so is a trailing comma. The dash in the date can be replaced with a single space.

 21 Jun,
 Purbrook , Waterlooville,
 England , Australia,
 ==========
 28 Jun,
 West Indies , South Africa,
 Purbrook , England,
 Australia , Waterlooville,
 ==========

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Model::Fixtures;

use strict;
use warnings;
use Carp;

use Regexp::Common;
use List::MoreUtils qw/any/;

use Slurp;
use Data::Dumper;

use ResultsSystem::Exception;

use ResultsSystem::Model;
use parent qw/ResultsSystem::Model/;

=head2 new

Constructor for the module. Accepts one parameter which
is the filename of the csv file to be read.

$f = Fixtures->new( -full_filename => "/xyz/fixtures/2008/division1.csv" );

The fixtures file is processed as part of the object creation process. There is no specific
error returned if the processing fails. This must be inferred from the messages in the Error object.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  my $err = 0;

  if ( $args->{-division} ) {
    $self->set_division( $args->{-division} );
    $err = $self->read_file();
  }

  $self->{logger} = $args->{-logger} if $args->{-logger};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};

  return $self if $err == 0;
  return;
}

=head2 get_full_filename

=cut

#***************************************
sub get_full_filename {

  #***************************************
  my $self = shift;
  if ( !$self->{FULLFILENAME} ) {
    my $c = $self->get_configuration;
    my $p = $c->get_path( -csv_files => 1 );
    my $s = $c->get_season;
    $self->{FULLFILENAME} = join( '/', $p, $s, $self->get_division );
  }
  croak ResultsSystem::Exception->new( 'FILE_DOES_NOT_EXIST', $self->{FULLFILENAME} )
    if !( -f $self->{FULLFILENAME} );
  return $self->{FULLFILENAME};
}

=head2 set_full_filename

Sets the full_filename. No validation or return code.

=cut

#***************************************
sub set_full_filename {

  #***************************************
  my $self = shift;
  $self->{FULLFILENAME} = shift;
  return $self;
}

=head2 get_date_list

Returns a reference to the array of dates.

$dates_ref = $f->get_date_list;
print $dates_ref->[0];

=cut

#***************************************
sub get_date_list {

  #***************************************
  my $self = shift;

  # Returns an array reference.
  return $self->{DATES};
}

=head2 get_week_fixtures

Returns an array reference. Each element of the array is a
hash element.

 $array_ref = $f->get_week_fixtures( -date => "01-Jun" );
 print $array_ref->[0]->{home};

=cut

#***************************************
sub get_week_fixtures {

  #***************************************
  my $self = shift;
  my %args = (@_);
  my %h;
  my @fixtures;

  my $i    = 0;
  my $more = 1;
  $self->logger->debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
  while ($more) {
    %h = $self->_get_fixture_hash( -date => $args{-date}, -index => $i );
    if ( ( !$h{home} ) || $i > 1000 ) {
      $self->logger->debug( "No more elements for date " . $args{-date} . ": i=" . $i );
      last;
    }
    push @fixtures, {%h};
    $i++;
  }
  return \@fixtures;
}

=head2 get_all_fixtures

Returns a list reference containing all the fixtures for the current division. 
Each element is a list ref containing the date and a list ref of fixtures for
that date.

Dates are in chronological order.

$list_ref = $f->get_all_fixtures;

  [
          [
            '7-May',
            [
              {
                'away' => 'Lymington 1',
                'home' => 'Langley Manor 1'
              },
              {
                'away' => 'Fawley',
                'home' => 'Hythe & Dibden'
              },
              {
                'away' => 'New Milton',
                'home' => 'Lymington 2'
              },
              {
                'away' => 'Bashley',
                'home' => 'Pylewell Park'
              }
            ]
          ],
          [
            '14-May',
            [
              {
                'away' => 'Langley Manor 1',
                'home' => 'Fawley'
              },
              {
                'away' => 'Lymington 2',
                'home' => 'Bashley'
              },
              {
                'away' => 'Hythe & Dibden',
                'home' => 'New Milton'
              },
              {
                'away' => 'Pylewell Park',
                'home' => 'Lymington 1'
              }
            ]
          ],
  ]

=cut

#***************************************
sub get_all_fixtures {

  #***************************************
  my $self  = shift;
  my %args  = (@_);
  my @dates = ();
  my @list  = ();

  if ( $self->{DATES} ) {
    @dates = @{ $self->{DATES} };
  }

  foreach my $d (@dates) {

    my $ref = $self->get_week_fixtures( -date => $d );
    push @list, [ $d, $ref ];

  }
  $self->logger->debug( Dumper \@list );
  return \@list;
}

=head2 get_all_teams

Returns an array reference containing a sorted hash list of teams in the division.

  eg $teams = $team_list_ref = $f->get_all_teams

  print $teams->[0]->{team};
  
=cut

# **************************************
sub get_all_teams {

  # **************************************
  my ( $self, %args ) = (@_);
  my ( @teams, @allteams, %h );

  # Get hash_ref containing all fixtures.
  my $all_fixtures = $self->get_all_fixtures;

  # Each key is a week which contains a list of fixtures.
  foreach my $d ( keys(%$all_fixtures) ) {

    # Loop through the fixtures and add the teams to the list.
    my $matches = $all_fixtures->{$d};
    foreach my $m (@$matches) {

      push @allteams, $m->{home};
      push @allteams, $m->{away};

    }

  }

  # From: http://www.antipope.org/Charlie/attic/perl/one-liner.html
  # Sort and eliminate duplicates.
  @teams = sort ( grep { ( $h{$_}++ == 1 ) || 0 } @allteams );

  @teams = map( { { team => $_ } } @teams );

  return \@teams;

}

=head2 read_file

Method which reads the fixtures file and loads it into an internal data structure.

Returns 0 if the file is successfully loaded and validated.

=cut

#***************************************
sub read_file {

  #***************************************
  my $self = shift;
  my @lines;
  my $err = 0;

  $self->{DATES} = [];
  eval {
    @lines = slurp( $self->get_full_filename );
    1;
  } || do {
    my $err2 = $@;
    croak $err2 if $err2 . "" !~ m/FILE_DOES_NOT_EXIST/;
    $self->logger->error($err2);
  };

  my $lines    = scalar(@lines);
  my $fixtures = 0;
  my $dates    = 0;
  my $dividers = 0;

  foreach my $l (@lines) {

    last if $err;

    $l = $self->_trim($l);
    if ( $self->_is_date($l) ) {
      $err = $self->_add_date($l);
      $dates++;
    }

    elsif ( $self->_is_fixture($l) && $err == 0 ) {
      if ( $self->_get_last_date ) {
        $self->_add_fixture( $self->_get_last_date, $l );
        $fixtures++;
      }
      else {
        $err = 1;
      }
    }
    else {
      $dividers++ if ( $l =~ m/^==========/x );
    }

  }
  $self->logger->debug( "Read "
      . $self->get_full_filename
      . " lines=$lines dates=$dates fixtures=$fixtures "
      . "dividers=$dividers err=$err" );
  return $err;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _is_date

Internal method which returns true if the string passed as an
argument is a date of the form DD-Mon. Trailing characters are accepted
so the following are valid: 10 May, 1 May, 01 May, 01 Mayxxxxx, 22 May,
10-May, 1-May, 15-November.

The following are not valid: 10-06-08, 10-06, 10-may

The three letters must match a month eg Jan, Feb, Mar, but not Fre.

=cut

#***************************************
sub _is_date {

  #***************************************
  my $self = shift;
  my $d    = shift;
  my $ret  = 0;
  if ( $d =~ m/^[0-9]{1,2}[ -][A-Z][a-z]{2}/x ) {
    $ret = 1 if any { $d =~ m/$_/x } qw / Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec /;
  }
  return $ret;
}

=head2 _is_fixture

Internal method which returns true if the string passed as an argument is a fixture.

It does this by looking for the comma between the team names. eg Locks Heath, Purbrook.
The comma can be surrounded by whitespace, but there must be at least one non-whitespace character
somewhere on either side of the comma.

Must also cope with abbreviations:

 01-Jun
 Hambledon C,Hambledon B
 Petersfield,Waterlooville
 U.S.,Portsmouth B

=cut

#***************************************
sub _is_fixture {

  #***************************************
  my $self = shift;
  my $f    = shift;
  my $ret  = 0;
  if ( !( $self->_is_date($f) ) ) {

    if ( $f =~ m/[\w.]\s*,\s*\w/x ) {
      $ret = 1;
    }

  }
  return $ret;
}

=head2 _add_date

Internal method which trims the date and adds it to the list of dates.

Dates are stored without a leading 0. So 09-May becomes 9-May.

=cut

#***************************************
sub _add_date {

  #***************************************
  my $self = shift;
  my $d    = shift;
  $d = $self->_trim($d);
  $d =~ s/^0//x;                                  # Remove leading zero.
  $d =~ s/^(\d{1,2}-[A-Z][A-Za-z]{2}).*$/$1/x;    # Remove trailing commas etc.
  push @{ $self->{DATES} }, $d;
  return 0;
}

=head2 _get_last_date

Internal method which returns the last element in the list of dates. Returns undef on failure.

=cut

#***************************************
sub _get_last_date {

  #***************************************
  my $self  = shift;
  my $d_ref = $self->{DATES};
  if ( !$d_ref ) {
    $self->logger->warn("_get_last_date() No dates defined.");
    return;
  }
  my @d_array = @$d_ref;
  my $d       = $d_array[ scalar(@d_array) - 1 ];
  return $d;
}

=head2 _add_fixture

Internal method which accepts a date and a fixture. The fixture is
a string which is added to the hash of fixtures for that date.

eg $f->_add_fixture( "04-May", "England, Australia" );

Returns 0 on success.

=cut

#***************************************
sub _add_fixture {

  #***************************************
  my $self = shift;
  my $d    = shift;
  my $f    = shift;
  my $err  = 0;
  $f = $self->_trim($f);
  if ( !$d ) {
    $self->logger->warn("_add_fixture() Undefined date parameter.");
    $err = 1;
  }
  if ( !$f ) {
    $self->logger->warn("_add_fixture() Undefined fixture parameter.");
    $err = 1;
  }
  return 1 if $err;

  if ( $self->{FIXTURES}{$d} ) {
    push @{ $self->{FIXTURES}{$d} }, $f;
  }
  else {
    my @a = ($f);
    @{ $self->{FIXTURES}{$d} } = @a;
  }

  # print $self->{FIXTURES}{"20-Apr"}[0] . "\n";
  return $err;

}

=head2 _get_fixture_hash

Internal method which accepts a date and an index and returns a hash
containing the home and away teams for that fixture. The index is 0 based.

%fh = $f->_get_fixture_hash( -date => "04-May", -index => 0 );
print $fh{home} . $fh{away} . "\n";

=cut

#***************************************
sub _get_fixture_hash {

  #***************************************
  my $self = shift;
  my %args = (@_);
  my %h    = ();

  $self->logger->debug( "_get_fixtures_hash() " . Dumper(%args) );
  $self->logger->debug( "_get_fixtures_hash() " . Dumper( $self->{FIXTURES} ) );

  croak ResultsSystem::Exception->new( 'FIXTURES_NOT_DEFINED', 'Has read_file been run?' )
    if !defined $self->{FIXTURES};
  my $l = $self->{FIXTURES}{ $args{-date} }[ $args{-index} ];

  if ($l) {
    $self->logger->debug( "_get_fixtures_hash() " . Dumper( $self->{FIXTURES} ) );
    $self->logger->debug( "_get_fixture_hash() " . $l );
    my @bits = split /,/x, $l;
    $h{home} = $self->_trim( $bits[0] );
    $h{away} = $self->_trim( $bits[1] );

    # print "line=$l. " . Dumper( @bits ) . "\n" . Dumper( %h ) . "\n";
    # print '$h{home}=' . $h{home} . "\n";
    if ( !defined( $h{home} ) || !defined( $h{away} ) ) {
      $self->logger->warn("_get_fixture_hash() Invalid line: $l");
    }

    # print "return hash.\n";
    return %h;

  }

  # print "return empty hash\n";
  return %h;
}

=head2 _trim

Internal method which removes leading and trailing whitespace from the string passed
as an argument.

$s = $self->_trim( $s );

=cut

#***************************************
sub _trim {

  #***************************************
  my $self = shift;
  my $l    = shift;
  $l =~ s/$RE{ws}{crop}//xg;

  #$l =~ s/^\s*([^\s])/$1/;
  #$l =~ s/([^\s])\s*$/$1/;
  return $l;
}

=head2 set_division

=cut

sub set_division {
  my ( $self, $v ) = @_;
  $self->{division} = $v;
  return $self;
}

=head2 get_division

=cut

sub get_division {
  my ($self) = @_;
  return $self->{division};
}

1;
