package ResultsSystem::Model::ResultsIndex;

use strict;
use warnings;
use Params::Validate qw/:all/;

=head1 NAME

ResultsSystem::Model::ResultsIndex

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This returns an array of hash refs used to build an index of the results for each division
and week.

It accesses the fixtures, not the results, because it needs to know the planned dates for fixtures
and well as those which have already been played.

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

  $self->set_arguments( [qw/ logger fixtures_model store_model /], $args );

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

=head2 set_fixtures_model

=cut

sub set_fixtures_model {
  my ( $self, $v ) = @_;
  $self->{fixtures_model} = $v;
  return $self;
}

=head2 get_fixtures_model

=cut

sub get_fixtures_model {
  my $self = shift;
  return $self->{fixtures_model};
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

  my $out = [];
  foreach my $division (@names) {

    my $dates = $self->_get_division_date_list( $division->{csv_file} );
    push @$out,
      {
      division  => $division->{csv_file},
      menu_name => $division->{menu_name},
      'dates'   => $dates
      };

  }

  return $out;

}

=head2 _get_division_date_list

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

# *********************************************************
sub _get_division_date_list {

  # *********************************************************
  my ( $self, $csv_file ) = validate_pos( @_, 1, 1 );

  my $dates_and_files =
    $self->get_store_model->get_dates_and_result_filenames_for_division($csv_file);

  return $dates_and_files;

}

1;

