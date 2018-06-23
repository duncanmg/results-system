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

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->{logger} = $args->{-logger} if $args->{-logger};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  $self->set_fixtures( $args->{-fixtures} )           if $args->{-fixtures};

  return $self;
}

=head2 run

=cut

# ******************************************************
sub run {

  # ******************************************************
  my ( $self, $args ) = @_;
  my $c = $self->get_configuration();

  return { all_dates => $self->get_all_dates_by_division(%$args), menu_names => $self->get_menu };

}

=head2 get_all_dates_by_division

Return a hash ref contatining all the dates for each division keyed by cvs file name.

  $VAR1 = {
            'U9S.csv' => [
                         '7-May',
                         '14-May',
                         '21-May',
                       ]
          };

=cut

sub get_all_dates_by_division {
  my ( $self, %args ) = @_;
  my $c = $self->get_configuration;

  my $dates = {};

  my @x = $c->get_menu_names;
  my $path = $c->get_path( -csv_files_with_season => 'Y' );
  $self->logger->debug($path);

  my $fixtures = $self->get_fixtures;

  foreach my $div (@x) {
    my $ff = $path . '/' . $div->{csv_file};
    $self->logger->debug($ff);
    eval {
      $fixtures->set_full_filename($ff);
      $fixtures->read_file();
      my $list = $fixtures->get_date_list;
      $dates->{ $div->{csv_file} } = $list if $list;
      $self->logger->error( "No fixtures for " . $path . '/' . $div->{csv_file} ) if !$list;
      1;
    } || do {
      my $err = $@;
      croak $err if ( $err !~ m/FILE_DOES_NOT_EXIST/ );
      $self->logger->warn(
        "$ff does not exist. Dates and fixtures for division will not be available.");
    };
  }
  $self->logger->debug(
    "Returning dates for these divisions: " . join( ", ", sort ( keys(%$dates) ) ) );
  return $dates;
}

=head2 get_menu

Returns a string containing the javascript for two arrays: menu_names and csv_files.

  if ( typeof( menu_names ) == "undefined" ) { menu_names = new Array(); }
  if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }

  menu_names.push( "U9N" );
  csv_files.push( "U9N.csv" );

  menu_names.push( "U9S" );
  csv_files.push( "U9S.csv" );

=cut

# *********************************************
sub get_menu {

  # *********************************************
  my ( $self, %args ) = @_;
  my $c = $self->get_configuration;
  my $line;

  my @x = $c->get_menu_names;

  $line = "if ( typeof( menu_names ) == \"undefined\" ) { menu_names = new Array(); }\n";

  $line = $line . "if ( typeof( csv_files ) == \"undefined\" ) { csv_files = new Array(); }\n\n";

  foreach my $x (@x) {

    $line = $line . "menu_names.push( \"" . $x->{menu_name} . "\" );\n";
    $line = $line . "csv_files.push( \"" . $x->{csv_file} . "\" );\n\n";

  }

  return $line;

}

=head2 set_fixtures

=cut

sub set_fixtures {
  my ( $self, $f ) = @_;
  $self->{fixtures} = $f;
  return $self;
}

=head2 get_fixtures

=cut

sub get_fixtures {
  my $self = shift;
  return $self->{fixtures};
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;

