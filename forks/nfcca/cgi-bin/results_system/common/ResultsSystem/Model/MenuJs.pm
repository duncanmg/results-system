package ResultsSystem::Model::MenuJs;

use strict;
use warnings;
use parent qw/ ResultsSystem::Model/;
use Data::Dumper;
use Carp;

=head1 NAME

ResultsSystem::Model::MenuJs

=cut

=head1 SYNOPSIS

  my $menu_js = ResultsSystem::Model::MenuJs->new(-logger => $logger, 
    -store_model => $store);

=cut

=head1 DESCRIPTION

This manages the dynamic javascript required by the menus.

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

  my $menu_js = ResultsSystem::Model::MenuJs->new( { -logger => $logger, 
    -store_divisions_model => $store } );

-logger : ResultsSystem::Logger

-store_model : ResultsSystem::Model::Store

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/logger store_model /], $args );

  return $self;
}

=head2 run

my $data = $self->run();

Returns a hash ref with two keys: all_dates and menu_names.

=cut

# ******************************************************
sub run {

  # ******************************************************
  my ($self) = @_;

  return { all_dates => $self->_get_all_dates_by_division(), menu_names => $self->_get_menu };

}

=head2 set_store_model

=cut

sub set_store_model {
  my ( $self, $f ) = @_;
  $self->{store_model} = $f;
  return $self;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_all_dates_by_division

Return a hash ref contatining all the dates for each division keyed by cvs file name.

  $VAR1 = {
            'U9S.csv' => [
                         '7-May',
                         '14-May',
                         '21-May',
                       ]
          };

=cut

sub _get_all_dates_by_division {
  my ($self) = @_;

  my $store = $self->_get_store_model;

  my $all_fixture_lists = $store->get_all_fixture_lists;

  my $dates = {};
  foreach my $k ( keys %$all_fixture_lists ) {
    my $f = $all_fixture_lists->{$k};
    my $d = [ map { $_->[0] } @$f ];
    $dates->{$k} = $d;
  }

  return $dates;
}

=head2 _get_menu

Returns a string containing the javascript for two arrays: menu_names and csv_files.

  if ( typeof( menu_names ) == "undefined" ) { menu_names = new Array(); }
  if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }

  menu_names.push( "U9N" );
  csv_files.push( "U9N.csv" );

  menu_names.push( "U9S" );
  csv_files.push( "U9S.csv" );

=cut

# *********************************************
sub _get_menu {

  # *********************************************
  my ($self) = @_;

  my $store = $self->_get_store_model;
  my $line;

  my @x = $store->get_menu_names;

  $line = "if ( typeof( menu_names ) == \"undefined\" ) { menu_names = new Array(); }\n";

  $line = $line . "if ( typeof( csv_files ) == \"undefined\" ) { csv_files = new Array(); }\n\n";

  foreach my $x (@x) {

    $line = $line . "menu_names.push( \"" . $x->{menu_name} . "\" );\n";
    $line = $line . "csv_files.push( \"" . $x->{csv_file} . "\" );\n\n";

  }

  return $line;

}

=head2 _get_store_model

=cut

sub _get_store_model {
  my $self = shift;
  return $self->{store_model};
}

1;

