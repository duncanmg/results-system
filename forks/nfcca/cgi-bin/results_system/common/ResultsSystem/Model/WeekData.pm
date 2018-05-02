  package ResultsSystem::Model::WeekData;

  use strict;
  use warnings;
  use Carp;

  use ResultsSystem::Exception;

  use parent qw/ ResultsSystem::Model /;

=head1 NAME

ResultsSystem::Model::WeekData

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Parent class for ResultsSystem::Model::WeekData::Reader and ResultsSystem::Model::WeekData::Writer.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model|http://www.results_system_nfcca.com:8088/ResultsSystem/Model>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

ResultsSystem::Model::WeekData->new( { -logger => $logger, $configuration => $configuration } );

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

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_labels

Returns a list of valid labels/keys for a results structure.

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
    my $w = $self->get_week;
    my $d = $self->get_division;

    croak( ResultsSystem::Exception->new( 'NO_DAT_WEEK',     'Week is not set.' ) )     if !$w;
    croak( ResultsSystem::Exception->new( 'NO_DAT_DIVISION', 'Division is not set.' ) ) if !$d;

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
