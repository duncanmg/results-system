  package ResultsSystem::Model::WeekData::Reader;

  use strict;
  use warnings;

  use Slurp;
  use List::MoreUtils qw / any /;

  use parent qw/ ResultsSystem::Model::WeekData /;

=head1 NAME

ResultsSystem::Model::WeekData::Reader

=cut

=head1 SYNOPSIS

Usage:

  my $wd = ResultsSystem::Model::WeekData->new( 
             { -logger => $logger, $configuration => $configuration } );

  $wd->set_week('1-May');
  $wd->set_division('U9S.csv');

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

=cut

=head1 INHERITS FROM

ResultsSystem::Model::WeekData

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

    my $ff = $self->get_full_dat_filename;
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

 Fields are : "team", "played", "result", "runs", "wickets", "performances", "resultspts", "battingpts", 
"bowlingpts", "totalpts"

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
    my $self   = shift;
    my $lineno = shift;
    return $self->{LINES}[$lineno];
  }

=head3 get_lines

Return all the lines as an array.

=cut

  sub get_lines {
    my $self = shift;
    return $self->{LINES};
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

=head3 set_division

=cut

  sub set_division {
    my ( $self, $v ) = @_;
    $self->{division} = $v;
    return $self;
  }

=head3 get_division

=cut

  sub get_division {
    my $self = shift;
    return $self->{division};
  }

=head3 set_week

=cut

  sub set_week {
    my ( $self, $v ) = @_;
    $self->{week} = $v;
    return $self;
  }

=head3 get_week

=cut

  sub get_week {
    my ( $self, $v ) = @_;
    return $self->{week};
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
    return 1;
  }

=head2 get_labels

=cut

  #***************************************
  sub get_labels {

    #***************************************
    my $self = shift;

    my @list = (
      "team",       "played",       "result",    "runs",
      "wickets",    "performances", "resultpts", "battingpts",
      "bowlingpts", "penaltypts",   "totalpts",  "pitchmks",
      "groundmks",  "facilitiesmks"
    );

    return @list;
  }

=head2 file_not_found

This method is used to indicate whether any results were found by the read_file method. Returns 1
if the file wasn't found.


These two calls set the value and return the new value.

 $i = $wd->file_not_found( 1 );
 $i = $wd->file_not_found( 0 );

This call returns the current value without changing it. 

 $i = $wd->file_not_found();

=cut

  #***************************************
  sub file_not_found {

    #***************************************
    my $self = shift;
    my $s    = shift;
    if ( $s =~ m/[01]/x ) {
      $self->{NO_FILE} = $s;
    }
    return $self->{NO_FILE};
  }

=head2 get_dat_filename

Returns the .dat filename for the week.

=cut

  #***************************************
  sub get_dat_filename {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my $f;
    my $w = $self->get_week     || "";
    my $d = $self->get_division || "";

    $d =~ s/\..*$//xg;    # Remove extension
    $f = $d . "_" . $w . ".dat";
    $f =~ s/\s//xg;

    return $f;
  }

=head2 get_full_dat_filename

Returns the .dat filename for the week complete with the csv path.

=cut

  #***************************************
  sub get_full_dat_filename {

    #***************************************
    my $self = shift;
    my $f    = $self->get_dat_filename;

    my $path = $self->get_configuration->get_path( -csv_files => 'Y' );
    my $season = $self->get_configuration->get_season;

    return $path . "/$season/" . $f;
  }

  1;
