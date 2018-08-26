
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

use Regexp::Common;
use List::MoreUtils qw/any/;

use Slurp;
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

  $self->set_arguments( [qw/store_divisions_model fixture_list_model logger configuration/],
    $args );

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

=head1 INTERNAL (PRIVATE) METHODS

=cut

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

1;
