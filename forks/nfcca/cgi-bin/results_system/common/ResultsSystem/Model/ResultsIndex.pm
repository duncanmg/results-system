
=head1 ResultsSystem::Model::ResultsIndex

=cut

=head1 Methods

=cut

package ResultsSystem::Model::ResultsIndex;

use strict;
use warnings;
use Params::Validate qw/:all/;

use ResultsSystem::Model;

use parent qw/ResultsSystem::Model/;

=head2 new

Constructor for the ResultIndex object. Inherits from Parent.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = validate_pos( @_, 1, 1 );
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger configuration fixtures_model /], $args );

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;
  my $list = $self->get_divisions_list;
  return $list;
}

=head2 get_division_date_list

=cut

# *********************************************************
sub get_division_date_list {

  # *********************************************************
  my ( $self, $dir, $file ) = validate_pos( @_, 1, 1, 1 );

  my $res_file;

  my $c      = $self->get_configuration;
  my $system = $c->get_system;

  my $fixtures = $self->get_fixtures_model;
  eval {
    $fixtures->set_full_filename("$dir/$file");
    $fixtures->read_file;
    1;
  } || do {
    my $err = $@;
    $self->logger->warn($err);
    return [];
  };

  my $dates = $fixtures->get_date_list;

  my $out = [];
  foreach my $d (@$dates) {

    $res_file =
        "results_system.pl?system="
      . $system
      . "&page=week_results&division="
      . $file
      . "&matchdate="
      . $d;

    push @$out, { 'matchdate' => $d, 'url' => $res_file };
  }

  $self->logger->debug( "$dir/$file contains " . scalar(@$out) . " dates." );

  return $out;

}

#=head2 output_html
#
#This method returns HTML for all the divisions. The HTML starts with a single level one
#heading. This is followed by the HTML for each division. This consists of a level two
#heading and a table. This list of divisions is read from the configuration file.
#
#( $err, $line ) = output_html;
#
#=cut
#
## *********************************************************
#sub output_html {
#
#  # *********************************************************
#  my $self = shift;
#  my $err  = 0;
#
#  my $q     = $self->get_query;
#  my $c     = $self->get_configuration;
#  my @names = $c->get_menu_names;
#  my ( $line, $l );
#  $self->logger->debug( scalar(@names) . " divisions to be listed." );
#
#  $line =
#      $line . "<h1>"
#    . $c->get_descriptors( -title => "Y" )
#    . " - Results "
#    . $c->get_descriptors( -season => "Y" )
#    . "</h1>\n";
#
#  $line = $line . $self->return_to_link("-results_index") . "\n";
#
#  my $d = $c->get_path( -csv_files => "Y" );
#  my $season = $c->get_season;
#  $d = "$d/$season";
#
#  foreach my $division (@names) {
#
#    eval {
#      ( $err, $l ) = $self->print_table( $d, $division->{csv_file}, $division->{menu_name} );
#      $line = $line . $l;
#    };
#    if ($@) {
#      $self->logger->error( "Problem processing " . $division->{menu_name} );
#      $self->logger->error( $@, 5 );
#      $err = 1;
#    }
#    if ( $err != 0 ) {
#      last;
#    }
#  }
#
#  return ( $err, $line );
#
#}

=head2 get_divisions_list

This method returns all the divisions. 

=cut

# *********************************************************
sub get_divisions_list {

  # *********************************************************
  my $self = shift;

  my $c     = $self->get_configuration;
  my @names = $c->get_menu_names;
  $self->logger->debug( scalar(@names) . " divisions to be listed." );

  my $d = $c->get_path( -csv_files => "Y" );
  my $season = $c->get_season;
  $d = "$d/$season";

  my $out = [];
  foreach my $division (@names) {

    my $dates = $self->get_division_date_list( $d, $division->{csv_file} );
    push @$out,
      {
      division  => $division->{csv_file},
      menu_name => $division->{menu_name},
      'dates'   => $dates
      };

  }

  return $out;

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

1;

