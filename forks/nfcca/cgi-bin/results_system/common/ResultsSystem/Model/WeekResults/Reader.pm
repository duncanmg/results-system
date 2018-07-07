  package ResultsSystem::Model::WeekResults::Reader;

  use strict;
  use warnings;

  use Slurp;
  use List::MoreUtils qw / any /;
  use Data::Dumper;

  use parent qw/ ResultsSystem::Model::WeekResults /;

  use overload '""' => 'stringify';

=head1 NAME

ResultsSystem::Model::WeekResults::Reader

=cut

=head1 SYNOPSIS

Usage:

  my $wd = ResultsSystem::Model::WeekResults->new( 
             { -logger => $logger, $configuration => $configuration } );

  $wd->set_full_filename('/a/b/U9S_1-May.dat');

  $wd->read_file();

  my $i = 0;
  while (1) {
    my $href = $wd->get_line($i);
    last if ! $href;
    $i++;

    # Processing ... 
  }

Can also use get_field to return a named field from a given line.

There is also get_lines().

=cut

=head1 DESCRIPTION

This reads the .dat file which contains the results for the given division
and week.

The file must exist and contain valid data.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model::WeekResults|http://www.results_system_nfcca.com:8088/ResultsSystem/Model/WeekResults>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head3 read_file

This method causes the object to read the saved results into an internal data structure. If no
results have been saved then the method file_no_found is set to return true.

The full filename must have been defined.

=cut

  #***************************************
  sub read_file {

    #***************************************
    my $self = shift;
    my @lines;

    my $ff = $self->get_full_filename;
    if ( !$ff ) {
      $self->logger->error("Full filename is not defined");
      return;
    }

    if ( !-f $ff ) {
      $self->logger->debug(
        "read_file(): No results have previously been saved for this division and week");
      $self->logger->debug("read_file(): $ff does not exist.");
      $self->file_not_found(1);
      return;
    }
    else {
      @lines = slurp($ff);
      $self->logger->debug(
        "read_file(): Results have previously been saved for this division and week");
      $self->logger->debug( "read_file(): " . scalar(@lines) . " lines read from $ff." );
      $self->file_not_found(0);
    }

    my $err = $self->process_lines( \@lines );

    return $err;
  }

=head3 get_field

 Arguments are: -type: match or line
 -lineno: 0 based
 -field: See list of valid names below.
 -team: Home or away. Only needed if -type is match.

 Fields are : "team", "played", "result", "runs", "wickets", "performances", 
 "resultspts", "battingpts", "bowlingpts", "totalpts"

 Returns null if the field or line does not exist or on error.

 e.g. $w->get_field( -type => "match", -lineno => 0, -team => "home", 
 -field => "team" );

=cut

  #***************************************
  sub get_field {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $err  = 0;
    my $l;

    if ( $args{-type} !~ m/^(?:line|match)$/x ) {
      $self->logger->error("get_field(): -type must be line or match.");
      $err = 1;
    }
    if ( $args{-lineno} !~ m/^[0-9][0-9]*$/x ) {
      $self->logger->error("get_field(): -lineno must be a number.");
      $err = 1;
    }
    if ( $args{-field} !~ m/^\w/x ) {
      $self->logger->error( "get_field(): -field is invalid." . $args{-field} );
      $err = 1;
    }
    if ( $err == 0 ) {

      $l = $args{-lineno} * 2;
      if ( $args{-type} eq "match" ) {
        if ( $args{-team} !~ m/^(?:home|away)$/x ) {
          $self->logger->error("-team must be home or away if -type is match.");
          $err = 1;
        }
        else {
          if ( $args{-team} =~ m/away/ ) {
            $l++;
          }
        }
      }

    }

    if ( $err == 0 ) {

      if ( $self->{LINES} ) {
        return @{ $self->{LINES} }[$l]->{ $args{-field} };
      }

    }

  }

=head3 get_line

Return the hash ref for the given line.

$wd->get_line($line_no);

=cut

  #***************************************
  sub get_line {

    #***************************************
    my ( $self, $lineno ) = @_;
    return $self->{LINES}->[$lineno];
  }

=head3 get_lines

Return all the lines as an array ref of hash refs.

=cut

  sub get_lines {
    my $self = shift;
    return $self->{LINES} || [];
  }

=head3 set_full_filename

=cut

  sub set_full_filename {
    my ( $self, $ff ) = @_;
    $self->{full_filename} = $ff;
    return $self;
  }

=head3 get_full_filename

=cut

  sub get_full_filename {
    my $self = shift;
    return $self->{full_filename};
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 process_lines

Fields are : "team", "played", "result", "runs", "wickets",
"performances", "resultpts", "battingpts", "bowlingpts", "penaltypts", "totalpts",
"pitchmks", "groundmks", "facilitiesmks"

=cut

  #***************************************
  sub process_lines {

    #***************************************
    my $self  = shift;
    my $l_ref = shift;
    my @lines = @$l_ref;
    my $err   = 0;
    $self->{LINES} = [];

    my @labels = (
      "team",       "played",       "result",    "runs",
      "wickets",    "performances", "resultpts", "battingpts",
      "bowlingpts", "penaltypts",   "totalpts",  "pitchmks",
      "groundmks",  "facilitiesmks"
    );

    foreach my $l (@lines) {

      my @bits = split /,/x, $l;

      my %team;
      for ( my $x = 0; $x < scalar(@labels); $x++ ) {

        $team{ $labels[$x] } = $bits[$x];

      }
      push @{ $self->{LINES} }, \%team;
    }
    $self->logger->debug( Dumper $self->{LINES} );
    return 1;
  }

=head2 stringify

Stringify the object to text containing the object type, the full filename and the results.

=cut

  sub stringify {
    my $self = shift;
    return
        ref($self)
      . ' Full filename: '
      . ( $self->get_full_filename || '' )
      . " Results:\n"
      . Dumper( $self->get_lines );
  }

  1;
