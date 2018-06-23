  package ResultsSystem::Model::SaveResults;

  use strict;
  use warnings;
  use Params::Validate qw/:all/;

  use Data::Dumper;

  use parent qw/ ResultsSystem::Model /;

  my $types = {
    positive_int => qr/^\d+$/x,
    int          => qr/^-*\d+$/x
  };

=head1 NAME

ResultsSystem::Model::SaveResults

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

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

    $self->set_arguments( [qw/configuration logger week_data_writer/], $args );

    return $self;
  }

=head2 run

=cut

  sub run {
    my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF } );

    $self->logger->debug( Dumper $args->{-params} );

    my $reformatted = $self->reformat( $args->{-params} );

    $self->logger->debug( Dumper $reformatted );

    my $writer = $self->get_week_data_writer();
    $writer->set_division( $args->{-params}->{division} );
    $writer->set_week( $args->{-params}->{matchdate} );

    $self->logger->debug('Call write_file');
    $writer->write_file($reformatted);

    return $reformatted;
  }

=head2 reformat

=cut

  sub reformat {
    my ( $self, $hr ) = validate_pos( @_, 1, { type => HASHREF } );

    my $tmp_hr = {};

    foreach my $key ( keys %$hr ) {

      my ( $ha, $name, $num ) = $key =~ m/^(home|away)(.*\D)(\d+)$/x;
      next if !$ha;

      $tmp_hr->{$num}->{$ha} = {} if !exists $tmp_hr->{$num};
      $tmp_hr->{$num}->{$ha}->{$name} = $hr->{$key};

    }

    my $out = [];
    foreach my $i ( sort { $a <=> $b } keys %$tmp_hr ) {
      push @$out, $tmp_hr->{$i}->{home};
      push @$out, $tmp_hr->{$i}->{away};
    }

    return $out;
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

    my $path = $self->get_configuration->get_path( -csv_files_with_season => 'Y' );

    return $path . "/" . $f;
  }

=head2 get_week_data_writer

=cut

  sub get_week_data_writer {
    my $self = shift;
    return $self->{week_data_writer};
  }

=head2 set_week_data_writer

=cut

  sub set_week_data_writer {
    my ( $self, $v ) = @_;
    $self->{week_data_writer} = $v;
    return $self;
  }

  1;
