
=head1 NAME

ResultsSystem::Model::Store

=cut

=head1 SYNOPSIS

  $f = Store->new( -logger => $logger, -configuration => $configuration,
    -fixture_list_model => $list, -store_divisions_model => $divisions );

=cut

=head1 DESCRIPTION

This module carries out operations on the modules in the store.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model|http://www.results_system_nfcca.com:8088/ResultsSystem/Model>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Model::Store;

use strict;
use warnings;
use Carp;

#use Regexp::Common;
use List::MoreUtils qw/any/;
use Params::Validate qw/:all/;

use Data::Dumper;

use ResultsSystem::Exception;

use ResultsSystem::Model;
use parent qw/ResultsSystem::Model/;

=head2 new

Constructor for the module. Accepts one parameter which
is the filename of the csv file to be read.

$f = Store->new( -logger => $logger, -configuration => $configuration, 
  -fixture_list_model => $list, -store_divisions_model => $divisions );

The fixtures file is processed as part of the object creation process if a full filename has been provided.
Otherwise it is not processed until the full filename is set and read_file is called.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments(
    [ qw/store_divisions_model fixture_list_model
        week_data_reader_model_factory logger configuration/
    ],
    $args
  );

  return $self;
}

=head2 get_all_fixture_lists

Returns a hash ref of csv file name and fixtures for all divisions.

          'U15S.csv' => [
                        [
                          '1-May',
                          [
                            {
                              'away' => 'Langley Manor',
                              'home' => 'Redlynch & Hale'
                            },
                          ]
                        ],
                      ],
          'U13N.csv' => [
                        [
                          '1-May',
                          [
                            {
                              'away' => 'Bramshaw',
                              'home' => 'Langley Manor 1'
                            },
                          ]
                        ],
                      ]

=cut

sub get_all_fixture_lists {
  my $self = shift;

  my @divisions = $self->get_store_divisions_model->get_menu_names;

  my $fl = $self->get_fixture_list_model;

  my $dir = $self->get_configuration->get_path( '-divisions_file_dir' => 1 );

  my $all = {};

  for my $d (@divisions) {
    $fl->set_full_filename( join( '/', $dir, $d->{csv_file} ) );
    $fl->read_file;
    $all->{ $d->{csv_file} } = $fl->get_all_fixtures;
  }

  return $all;
}

=head2 get_menu_names

Calls the get_menu_names method of L<ResultsSystem::Model::Store::Divisions>
and returns the result.

=cut

sub get_menu_names {
  my $self = shift;
  return $self->get_store_divisions_model->get_menu_names;
}

=head2 get_all_week_results_for_division

Accepts the name of the csv_file for the division and returns a
list of the WeekResults::Reader objects for the division.

my $list = $self->get_all_week_results_for_division('U9.csv');

my $list = $self->get_all_week_results_for_division();

If the csv file is not provided, it will try the one in the configuration
(get_configuration->get_csv_file).

=cut

sub get_all_week_results_for_division {
  my ( $self, $csv_file ) = validate_pos( @_, 1, 0 );

  $csv_file ||= $self->get_configuration->get_csv_file;
  my $files = $self->_get_all_week_files($csv_file);

  return $self->_extract_data($files);
}

=head2 get_dates_and_result_filenames_for_division

  $store->get_dates_and_result_filenames_for_division('U9N.csv'),

Should return

  [ { file =>
        '/home/duncan/git/results_system/forks/nfcca/results_system/' 
        . 'fixtures/nfcca/2017/U9N_1-May.dat',
      matchdate => '1-May'
    },
    { file =>
        '/home/duncan/git/results_system/forks/nfcca/results_system/' 
        . 'fixtures/nfcca/2017/U9N_8-May.dat',
      matchdate => '8-May'
    },
    { file =>
        '/home/duncan/git/results_system/forks/nfcca/results_system/' 
        . 'fixtures/nfcca/2017/U9N_15-May.dat',
      matchdate => '15-May'
    }
  ],

=cut

sub get_dates_and_result_filenames_for_division {
  my ( $self, $csv_file ) = validate_pos( @_, 1, { regex => qr/\.csv$/x } );
  my $files           = $self->_get_all_week_files($csv_file);
  my $files_and_dates = [];
  foreach my $f (@$files) {
    my $d = $self->_extract_date_from_result_filename($f);
    push( @$files_and_dates, { 'matchdate' => $d, 'file' => $f } );
  }
  return $files_and_dates;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _extract_date_from_result_filename

  $self->_extract_date_from_result_filename('County1_28-Jun.dat');

Should return '28-Jun'.

=cut

sub _extract_date_from_result_filename {
  my ( $self, $result_filename ) = validate_pos( @_, 1, { regex => qr/\.dat$/x } );
  my ($d) = $result_filename =~ m/_(\d{1,2}\D[A-Z][a-z]{2})\.dat$/x;
  croak(
    ResultsSystem::Exception->new(
      'BAD_RESULTS_FILENAME', "Could not extract date from $result_filename"
    )
  ) if !$d;
  return $d;
}

=head2 _get_all_week_files

This method returns a list of the result files for a given division. The division is
specified by passing the csv filename eg 'U9N.csv'.

The files are list in the order returned by the directory list command. On Linux, this will
normally be alphanumeric.

Reads all the files in the csv directory specified in the configuration. It then loads all those
that match the specified pattern into a list.

It is assumed that there is a relationship between the name of the csv file of the division and the
names of the week files for that division. Specifically, the name of a week file will be produced by
removing the extension from the csv filename, adding an underscore and the date for the week. So
County1.csv has associated week files called County1_21-Jun.dat, County1_28-Jun.dat, etc.

This method selects the week files by using a pattern which consists of the csv basename plus an underscore.
Thus the pattern for "County1.csv" is "County1_".

The method returns a reference to the list of week files.

  $list_ref = $lt->_get_all_week_files('U9N.csv');

=cut

#***************************************
sub _get_all_week_files {

  #***************************************
  my ( $self, $csv ) = validate_pos( @_, 1, { regex => qr/^\w+\.csv$/x } );
  my ( $FP, @files );

  my $dir = $self->build_csv_path;

  $csv =~ s/\..*$//xg;    # Remove extension

  opendir( $FP, $dir )
    || do { croak( ResultsSystem::Exception->new( 'UNABLE_TO_OPEN_DIR', $! ) ); };

  @files = readdir $FP;
  $self->logger->debug( scalar(@files) . " files retrieved from $dir." );
  close $FP;

  my $pattern = $csv . "_";
  @files = grep {/^$pattern/x} @files;
  $self->logger->debug(
    scalar(@files) . " of these files are week files for the division. " . $csv );

  @files = map { join( '/', $dir, $_ ) } @files;

  return \@files;

}

=head2 build_csv_path

Returns the directory where the week result (.dat) files for the current season can be found.

Assumed to be the same as where the csv files can be found.

=cut

sub build_csv_path {
  my $self = shift;
  my $c    = $self->get_configuration;

  my $dir = $c->get_path( -csv_files_with_season => "Y" );

  croak(
    ResultsSystem::Exception->new(
      'DIR_NOT_FOUND', "Directory for csv files not found. " . $dir
    )
  ) if !-d $dir;
  return $dir;
}

=head2 _extract_data

This method accepts a reference to a list of week files. It then loops
through the files and creates a list of WeekResults objects. Each WeekResults
object contains the data for one week.

 $week_data_list = $lt->_extract_data( \@files );

=cut

#***************************************
sub _extract_data {

  #***************************************
  my ( $self, $files_ref ) = validate_pos( @_, 1, 1 );
  my $week_data_list = [];

  foreach my $f (@$files_ref) {

    $self->logger->debug($f);
    $self->logger->debug( "Create WeekResults object " . $f );

    my $wd = $self->get_week_data_reader_model_factory->();
    $wd->set_full_filename($f);
    $wd->read_file;

    push @$week_data_list, $wd;

  }

  return $week_data_list;
}

=head2 get_store_divisions_model

=cut

sub get_store_divisions_model {
  my $self = shift;
  return $self->{store_divisions_model};
}

=head2 set_store_divisions_model

=cut

sub set_store_divisions_model {
  my ( $self, $v ) = @_;
  $self->{store_divisions_model} = $v;
  return $self;
}

=head2 get_fixture_list_model

=cut

sub get_fixture_list_model {
  my $self = shift;
  return $self->{fixture_list_model};
}

=head2 set_fixture_list_model

=cut

sub set_fixture_list_model {
  my ( $self, $v ) = @_;
  $self->{fixture_list_model} = $v;
  return $self;
}

=head2 get_week_data_reader_model_factory

=cut

sub get_week_data_reader_model_factory {
  my $self = shift;
  return $self->{week_data_reader_model_factory};
}

=head2 set_week_data_reader_model_factory

=cut

sub set_week_data_reader_model_factory {
  my ( $self, $v ) = @_;
  $self->{week_data_reader_model_factory} = $v;
  return $self;
}

1;
