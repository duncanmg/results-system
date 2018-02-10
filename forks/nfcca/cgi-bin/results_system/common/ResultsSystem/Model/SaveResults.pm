  # **************************************************************
  #
  # Name: SaveResults.pm
  #
  # **************************************************************

  package ResultsSystem::Model::SaveResults;

  use strict;
  use warnings;
  use Params::Validate qw/:all/;

  use Data::Dumper;

  use parent qw/ ResultsSystem::Model /;

  my $types = {
    positive_int => qr/^\d+$/,
    int          => qr/^-*\d+$/
  };

=head1 SaveResults.pm

=cut

=head1 Methods

=cut

=head3 External Methods (API)

=cut

=head3 new

ResultsSystem::Model::SaveResults->new( { -logger => $logger, $configuration => $configuration } );

Can also accept -division, -week

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

    return $self;
  }

=head3 run

=cut

  sub run {
    my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF } );

    $self->logger->debug( Dumper $args->{-params} );

    my $reformatted = $self->reformat( $args->{-params} );

    $self->logger->debug( Dumper $reformatted );

  }

=head3 reformat

=cut

  sub reformat {
    my ( $self, $hr ) = validate_pos( @_, 1, { type => HASHREF } );

    my $out = [];

    my $rename = sub {
      my ( $hr, $k, $ha, $match, $new_hr ) = @_;
      $self->logger->debug("test $k, $ha $match");
      my @bits = $k =~ m/^$ha(.*\D)$match$/;
      $self->logger->debug( Dumper @bits );
      if (@bits) {
        $new_hr->{ $bits[0] } = $hr->{$k};
      }
      return $new_hr;
    };

    my $prune = sub {
      my ( $hr, $match ) = @_;
      foreach my $k (keys %$hr) {
        delete $hr->{$k} if ( $k =~ m/^.*$match$/ );
      }
      return $hr;
    };

    my $match = 0;
    while ( 1 == 1 ) {
      my $home_hr = {};
      my $away_hr = {};
      foreach my $k ( keys %$hr ) {

        $home_hr = $rename->( $hr, $k, 'home', $match, $home_hr );
        $away_hr = $rename->( $hr, $k, 'away', $match, $away_hr );

      }
      last if !( keys %$home_hr );
      push @$out, $home_hr, $away_hr;
      $hr = $prune->( $hr, $match );
      $match++;
    }

    return $out;
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

=head2 Internal (Private) Methods

=cut

=head3 get_labels

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

=head3 file_not_found

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

=head2 get_dat_filename

Returns the .dat filename for the week.

=cut

  #***************************************
  sub get_dat_filename {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my $f;
    my $w = $self->get_week;
    my $d = $self->get_division;

    $d =~ s/\..*$//g;    # Remove extension
    $f = $d . "_" . $w . ".dat";
    $f =~ s/\s//g;

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
