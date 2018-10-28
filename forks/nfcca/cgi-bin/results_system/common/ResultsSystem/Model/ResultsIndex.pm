package ResultsSystem::Model::ResultsIndex;

use strict;
use warnings;
use Params::Validate qw/:all/;
use Data::Dumper;
use DateTime::Tiny;
use ResultsSystem::Exception;

=head1 NAME

ResultsSystem::Model::ResultsIndex

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This returns an array of hash refs used to build an index of the results for each division
and week.

Note that the .htm files are not treated as part of the store/database. They are part of the view.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

use ResultsSystem::Model;

use parent qw/ResultsSystem::Model/;

=head2 new

Constructor for the ResultIndex object.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = validate_pos( @_, 1, 1 );
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger store_model results_dir results_dir_full /], $args );

  return $self;
}

=head2 run

  $list = $ri->run();

Returns the output of _get_divisions_list().

=cut

sub run {
  my ( $self, $args ) = @_;
  my $list = $self->_get_divisions_list;
  return $list;
}

=head2 set_store_model

=cut

sub set_store_model {
  my ( $self, $v ) = @_;
  $self->{store_model} = $v;
  return $self;
}

=head2 get_store_model

=cut

sub get_store_model {
  my $self = shift;
  return $self->{store_model};
}

=head2 set_results_dir

=cut

sub set_results_dir {
  my ( $self, $v ) = @_;
  $self->{results_dir} = $v;
  return $self;
}

=head2 get_results_dir

=cut

sub get_results_dir {
  my $self = shift;
  return $self->{results_dir};
}

=head2 set_results_dir_full

=cut

sub set_results_dir_full {
  my ( $self, $v ) = @_;
  $self->{results_dir_full} = $v;
  return $self;
}

=head2 get_results_dir_full

=cut

sub get_results_dir_full {
  my $self = shift;
  return $self->{results_dir_full};
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_divisions_list

This method returns all the divisions. 

This method returns an array ref of hash refs.

Each hash ref has three elements: division, menu_name and dates.

  [
    { 
	division => 'U9N.csv',
	menu_name => 'U9 North',
	dates     => 
        [ 
          { 
            'matchdate' => '8-Jun', 
            'url' => '/results_system/custom/nfcca/2017/results/U9N_8-Jun.htm'
          },
          {
            'matchdate' => '15-Jun', 
            'url' => '/results_system/custom/nfcca/2017/results/U9N_15-Jun.htm'
          }
                   
        ]
    }
  ]

=cut

# *********************************************************
sub _get_divisions_list {

  # *********************************************************
  my $self = shift;

  my @names = $self->get_store_model->get_menu_names;
  $self->logger->debug( scalar(@names) . " divisions to be listed." );
  $self->logger->debug( Dumper @names );

  my $out = [];
  foreach my $division (@names) {

    my $dates = $self->_get_all_week_htm_files( $division->{csv_file} );
    $dates = $self->_sort_by_date($dates);

    push @$out,
      {
      division  => $division->{csv_file},
      menu_name => $division->{menu_name},
      'dates'   => $dates
      };

  }

  return $out;

}

=head2 _get_all_week_htm_files

This reads all the files in the directory given by $self->get_results_dir full.

It then filters the list and removes those which do not begin with the division
basename followed by an underscore. eg "U9N_".

It creates a relative url for each filename based on the value returned by
$self->get_results_dir.

It constructs the matchdate from the filename.

It returns an array ref of list refs.

$self->_get_all_week_htm_files('U9.csv');

  [
    { 
      'matchdate' => '8-Jun', 
      'url' => '/results_system/custom/nfcca/2017/results/U9N_8-Jun.htm'
    },
    {
      'matchdate' => '15-Jun', 
      'url' => '/results_system/custom/nfcca/2017/results/U9N_15-Jun.htm'
    }
  ]

=cut

#***************************************
sub _get_all_week_htm_files {

  #***************************************
  my ( $self, $csv ) = validate_pos( @_, 1, { regex => qr/^\w+\.csv$/x } );
  my ( $FP, @files );

  my $dir = $self->get_results_dir_full;
  croak( ResultsSystem::Exception->new( 'REQUIRED', 'results_dir_full is not set' ) ) if !$dir;

  my $url_root = $self->get_results_dir;
  croak( ResultsSystem::Exception->new( 'REQUIRED', 'results_dir is not set' ) ) if !$url_root;

  opendir( $FP, $dir )
    || do { croak( ResultsSystem::Exception->new( 'UNABLE_TO_OPEN_DIR', $! ) ); };

  @files = readdir $FP;
  $self->logger->debug( scalar(@files) . " files retrieved from $dir." );
  close $FP;

  $csv =~ s/\..*$//xg;    # Remove extension
  my $pattern = $csv . "_";    # eg U9N_

  @files = grep {/^$pattern/x} @files;
  $self->logger->debug(
    scalar(@files) . " of these files are html result files for the division. " . $csv );

  my @out = ();
  foreach my $f (@files) {
    my $md = $f;
    $md =~ s/^$pattern(.+)\.htm$/$1/x;
    push @out, { matchdate => $md, url => join( '/', $url_root, $f ) };
  }

  return \@out;

}

=head2 _sort_by_date

Accepts an array of hash refs. Each hash ref must have a "matchdate" containing
a date of the form "1-Jun" or "12 Jun".

Returns the array ref sorted by ascending matchdate.

=cut

sub _sort_by_date {
  my ( $self, $data ) = validate_pos( @_, 1, { type => ARRAYREF } );

  my $months = {
    'Jan' => '01',
    'Feb' => '02',
    'Mar' => '03',
    'Apr' => '04',
    'May' => '05',
    'Jun' => '06',
    'Jul' => '07',
    'Aug' => '08',
    'Sep' => '09',
    'Oct' => '10',
    'Nov' => '11',
    'Dec' => '12'
  };

  foreach my $f (@$data) {
    my ( $d, $m ) = $f->{matchdate} =~ m/^(\d{1,2})[\s-](\w{3})$/xi;
    $f->{sortable} = sprintf( '%02d%02d', $months->{$m}, $d );
  }

  my @sorted = sort { $a->{sortable} <=> $b->{sortable} } @$data;

  my $delete_sortable = sub { delete $_[0]->{sortable}; $_[0]; };
  @sorted = map { $delete_sortable->($_) } @sorted;

  return \@sorted;
}

1;

