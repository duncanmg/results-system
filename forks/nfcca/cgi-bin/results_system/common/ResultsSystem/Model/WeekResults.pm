  package ResultsSystem::Model::WeekResults;

  use strict;
  use warnings;
  use Carp;

  use ResultsSystem::Exception;

  use parent qw/ ResultsSystem::Model /;

=head1 NAME

ResultsSystem::Model::WeekResults

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Parent class for ResultsSystem::Model::WeekResults::Reader and ResultsSystem::Model::WeekResults::Writer.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model|http://www.results_system_nfcca.com:8088/ResultsSystem/Model>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

ResultsSystem::Model::WeekResults->new( { -logger => $logger, -configuration => $configuration, 
-full_filename => $full_filename } );

=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    my %args = %$args;

    $self->set_configuration( $args{-configuration} ) if $args{-configuration};

    $self->set_full_filename( $args{-full_filename} ) if $args{-full_filename};

    $self->set_logger( $args{-logger} ) if $args{-logger};

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

=head2 get_default_result

Returns the default structure for a result.

Returns an array ref of hash refs. Each hash ref contains the
name of the element and its default value.

eg

    { name => "team",          value => "" },
    { name => "played",        value => 'N' },

=cut

  #***************************************
  sub get_default_result {

    #***************************************
    my $self = shift;

    my $list = [
      { name => "team",          value => "" },
      { name => "played",        value => 'N' },
      { name => "result",        value => 'W' },
      { name => "runs",          value => 0 },
      { name => "wickets",       value => 0 },
      { name => "performances",  value => "" },
      { name => "resultpts",     value => 0 },
      { name => "battingpts",    value => 0 },
      { name => "bowlingpts",    value => 0 },
      { name => "penaltypts",    value => 0 },
      { name => "totalpts",      value => 0 },
      { name => "pitchmks",      value => 0 },
      { name => "groundmks",     value => 0 },
      { name => "facilitiesmks", value => 0 },
    ];

    return $list;
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

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_labels

Returns a list of valid labels/keys for a results structure.

=cut

  #***************************************
  sub get_labels {

    #***************************************
    my $self = shift;

    return map { $_->{name} } @{ $self->get_default_result };
  }

  1;
