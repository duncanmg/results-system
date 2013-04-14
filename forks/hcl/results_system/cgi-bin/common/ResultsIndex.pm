#! /usr/bin/perl

# ***********************************************************
#
# Name: ResultsIndex.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ***********************************************************

=head1 ResultsIndex

=cut

=head1 Methods

=cut

{

  package ResultsIndex;

  use strict;
  use CGI;

  use Fixtures;
  use ResultsConfiguration;

  our @ISA;
  unshift @ISA, "Parent";

=head2 new

Constructor for the ResultIndex object. Inherits from Parent.

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );
    $self->logger->debug("ResultsIndex object created.");

    return $self;
  }

=head2 print_table

 ( $err, $l ) = $lt->print_table( "dir for csv_files", "csv_file", "title of division" );
 
This method returns the HTML for one division. The HTML consists of a title and a table. Each
cell in the table contains a date and a link to the results for that date. The dates are read
from the csv file for the division.

=cut

  # *********************************************************
  sub print_table {

    # *********************************************************
    my $self = shift;
    my $dir  = shift;
    my $file = shift;
    my $name = shift;
    my $res_file;
    my $c   = $self->get_configuration;
    my $err = 0;
    my $q   = $self->get_query;

    my $line = "<h2>" . $name . "</h2>\n";

    $line = $line . "<table>\n";

    my $f = Fixtures->new( -full_filename => "$dir/$file" );
    $self->logger->debug( $Fixtures::create_errmsg, 5 ) if !$f;
    my $d_ref = $f->get_date_list if $f;
    if ( !$d_ref ) {
      $self->logger->debug("No dates found. $dir/$file");
      $err = 1;
      return $err;
    }

    my @dates    = @$d_ref;
    my $counter  = 1;
    my $num_cols = 6;           # Columns in each row of table.
    my $col      = $num_cols;

    foreach my $d (@dates) {

      $res_file = $file;
      $res_file =~ s/^.*\/([^\/]*)$/$1/;
      $res_file =~ s/\.[^.]*$//;
      $res_file = $res_file . $counter . ".htm";

      $res_file =
          "results_system.pl?system="
        . $q->param("system")
        . "&page=week_results&division="
        . $file
        . "&matchdate="
        . $d;

      my $dir = $c->get_path( -csv_files => "Y" );
      my $h = "<a href=\'$res_file\'>" . $d . "</a>";

      if ( $col == $num_cols ) {
        $line = $line . "<tr>";
      }
      $line = $line . "<td>" . $h . "</td>";

      if ( $col <= 1 ) {
        $line = $line . "</tr>\n";
        $col  = $num_cols;
      }
      else {
        $col--;
      }

      $counter++;
    }
    if ( $col >= 1 ) {
      while ( $col >= 1 ) {
        $line = $line . "<td>-</td>";
        $col--;
      }
      $line = $line . "</tr>";
    }

    $line = $line . "</table>\n";
    return ( $err, $line );

  }

=head2 output_html

This method returns HTML for all the divisions. The HTML starts with a single level one
heading. This is followed by the HTML for each division. This consists of a level two
heading and a table. This list of divisions is read from the configuration file.

( $err, $line ) = output_html;

=cut

  # *********************************************************
  sub output_html {

    # *********************************************************
    my $self = shift;
    my $err  = 0;

    my $q     = $self->get_query;
    my $c     = $self->get_configuration;
    my @names = $c->get_menu_names;
    my ( $line, $l );
    $self->logger->debug( scalar(@names) . " divisions to be listed." );

    $line =
        $line . "<h1>"
      . $c->get_descriptors( -title => "Y" )
      . " - Results "
      . $c->get_descriptors( -season => "Y" )
      . "</h1>\n";

    $line = $line . $self->return_to_link("-results_index") . "\n";

    my $d = $c->get_path( -csv_files => "Y" );
    my $season = $c->get_season;
    $d = "$d/$season";

    foreach my $division (@names) {

      eval {
        ( $err, $l ) = $self->print_table( $d, $division->{csv_file}, $division->{menu_name} );
        $line = $line . $l;
      };
      if ($@) {
        $self->logger->debug( "Problem processing " . $division->{menu_name} );
        $self->logger->debug( $@, 5 );
        $err = 1;
      }
      if ( $err != 0 ) {
        last;
      }
    }

    return ( $err, $line );

  }

  1;

}

