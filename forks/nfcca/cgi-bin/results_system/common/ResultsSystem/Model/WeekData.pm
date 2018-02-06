  # **************************************************************
  #
  # Name: WeekData.pm
  #
  # 0.1  - 27 Jun 08 - POD added.
  #
  # **************************************************************

  package ResultsSystem::Model::WeekData;

  use strict;
  use warnings;

  use Slurp;
  use List::MoreUtils qw / any /;

  use parent qw/ ResultsSystem::Model /;

=head1 WeekData.pm

=cut

=head1 Methods

=cut

=head2 new

ResultsSystem::Model::WeekData->new( { -logger => $logger, $configuration => $configuration } );

Can also accept -division, -week, -full_filename

=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    my %args = %$args;

    $self->set_configuration( $args{-configuration} ) if $args{-configuration};

    $self->set_logger( $args{-logger} ) if $args{-logger};

    $self->set_division( $args{-division} ) if $args{-division};

    $self->set_week( $args{-week} ) if ( $args{-week} );

    $self->set_full_filename( $args{-full_filename} ) if $args{-full_filename};

    return $self;
  }

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

      my @bits = split /,/, $l;

      my %team;
      for ( my $x = 0; $x < scalar(@labels); $x++ ) {

        $team{ $labels[$x] } = $bits[$x];

      }
      push @{ $self->{LINES} }, \%team;
    }
    return $err;
  }

=head2 get_field

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

    if ( $args{-type} !~ m/^((line)|(match))$/ ) {
      $self->logger->error("get_field(): -type must be line or match.");
      $err = 1;
    }
    if ( $args{-lineno} !~ m/^[0-9][0-9]*$/ ) {
      $self->logger->error("get_field(): -lineno must be a number.");
      $err = 1;
    }
    if ( $args{-field} !~ m/^\w/ ) {
      $self->logger->error( "get_field(): -field is invalid." . $args{-field} );
      $err = 1;
    }
    if ( $err == 0 ) {

      $l = $args{-lineno} * 2;
      if ( $args{-type} eq "match" ) {
        if ( $args{-team} !~ m/^((home)|(away))$/ ) {
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

  #***************************************
  sub get_line {

    #***************************************
    my $self   = shift;
    my $lineno = shift;
    return $self->{LINES}[$lineno];
  }

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

=head2 set_field

 Arguments are: -type: match or line
 -lineno: 0 based
 -field: See list of valid names below.
 -team: Home or away. Only needed if -type is match.
 -value
 
 Fields are : "team", "played", "result", "runs", "wickets",
      "performances", "resultspts", "battingpts", "bowlingpts", "totalpts"

 Returns 0 on success, 1 on error.

 e.g. $w->set_field( -type => "match", -lineno => 0, -team => "home", 
 -field => "team", -value => "Hamble A" );
 
=cut

  #***************************************
  sub set_field {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $err  = 0;
    my $l;

    if ( $args{-type} !~ m/^((line)|(match))$/ ) {
      $self->logger->error("set_field(): -type must be line or match.");
      $err = 1;
    }
    if ( $args{-lineno} !~ m/^[0-9][0-9]*$/ ) {
      $self->logger->error("set_field(): -lineno must be a number.");
      $err = 1;
    }
    if ( $args{-field} !~ m/^\w/ ) {
      $self->logger->error( "set_field(): -field is invalid." . $args{-field} );
      $err = 1;
    }
    if ( !any { $args{-field} eq $_ } $self->get_labels ) {
      $self->logger->error(
        "set_field(): -field is not in list of valid fields." . $args{-field} );
      $err = 1;
    }
    if ( $err == 0 ) {

      $l = $args{-lineno} * 2;
      if ( $args{-type} eq "match" ) {
        if ( $args{-team} !~ m/^((home)|(away))$/ ) {
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
      if ( $args{-field} =~ m/runs|wickets|resultpts|battingpts|bowlingpts|totalpts|penaltypts/ )
      {
        if ( ( $args{-value} ) && ( $args{-value} !~ m/^[0-9]+$/ ) ) {
          $self->logger->error("$args{-field} must be a positive integer or empty.");
          $err = 1;
        }
      }
    }

    if ( $err == 0 ) {
      if ( $args{-field} eq "totalpts" ) {
        if ( ( $args{-value} ) && ( $args{-value} !~ m/^-{0,1}[0-9]+$/ ) ) {
          $self->logger->error("$args{-field} must be an integer or empty.");
          $err = 1;
        }
      }
    }

    if ( $err == 0 ) {
      if ( $args{-field} eq "played" ) {
        if ( $args{-value} !~ m/^[YNA]$/ ) {
          $self->logger->error("$args{-field} must be Y,N or A");
          $err = 1;
        }
      }
    }

    if ( $err == 0 ) {

      if ( @{ $self->{LINES} }[$l] ) {
        @{ $self->{LINES} }[$l]->{ $args{-field} } = $args{-value};
      }
      else {
        my %h = ( $args{-field} => $args{-value} );
        @{ $self->{LINES} }[$l] = \%h;
      }

    }
    return $err;
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
    if ( $s =~ m/[01]/ ) {
      $self->{NO_FILE} = $s;
    }
    return $self->{NO_FILE};
  }

=head2 read_file

This method causes the object to read the saved results into an internal data structure. If no
results have been saved then the method file_no_found is set to return true.

The full filename must have been defined.

=cut

  #***************************************
  sub read_file {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my @lines;

    my $ff = $self->get_full_filename;
    if ( !$ff ) {
      $self->logger->error("Full filename is not defined");
      $err = 1;
    }
    if ( $err == 0 ) {
      if ( !-f $ff ) {
        $self->logger->debug(
          "read_file(): No results have previously been saved for this division and week");
        $self->logger->debug("read_file(): $ff does not exist.");
        $self->file_not_found(1);
      }
      else {
        @lines = slurp($ff);
        $self->logger->debug(
          "read_file(): Results have previously been saved for this division and week");
        $self->logger->debug( "read_file(): " . scalar(@lines) . " lines read from $ff." );
        $self->file_not_found(0);
      }
    }
    if ( $err == 0 ) {
      $err = $self->process_lines( \@lines );
    }
    return $err;
  }

=head2 write_file

This writes the current contents of the data structure to the results file for the division and week.

=cut

  #***************************************
  sub write_file {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my $FP;

    my @labels = get_labels;

    my $ff = $self->get_full_filename;
    if ( !$ff ) {
      $err = 1;
    }

    if ( !$self->{LINES} ) {
      $err = 1;
      $self->logger->error("Nothing to write to file.");
    }
    else {

      if ( !open( $FP, ">", $ff ) ) {
        $self->logger->error("WeekData(): Unable to open file for writing. $ff.");
        $err = 1;
      }

    }

    if ( $err == 0 ) {

      foreach my $line ( @{ $self->{LINES} } ) {

        foreach my $label (@labels) {

          if ( ( !$line->{$label} )
            && ( $label !~ m/(team)|(played)|(result[^p])|(performances)/ ) )
          {
            $line->{$label} = 0;
          }

          # Commas or new lines will really mess things up!
          $line->{$label} =~ s/[,<>|\n]/ /g;
          print $FP $line->{$label} . ",";

        }

        print $FP "\n";

      }

    }

    if ($FP) {
      close $FP;
    }

    return $err;
  }

=head2 set_full_filename

=cut

  sub set_full_filename {
    my ( $self, $ff ) = @_;
    $self->{full_filename} = $ff;
    return $self;
  }

=head2 get_full_filename

=cut

  sub get_full_filename {
    my $self = shift;
    return $self->{full_filename};
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
    my $self = shift;
    return $self->{division};
  }

=head2 set_week

=cut

  sub set_week {
    my ( $self, $v ) = @_;
    $self->{week} = $v;
    return $self;
  }

=head2 get_week

=cut

  sub get_week {
    my ( $self, $v ) = @_;
    return $self->{week};
  }

  1;
