package GroundMarkings;

use strict;
use warnings;
use Parent;
use LeagueTable;
use Data::Dumper;
use Clone qw/ clone /;
use Text::CSV;

use parent "Parent";

sub new {
  my ( $class, %args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->initialise( \%args );
  return $self;
}

sub output_csv {
  my $self   = shift;
  my $config = $self->get_configuration;
  my @menus  = $config->get_menu_names;
  my $data   = [ [ "Week", "Division", "Home", "Away", "Pitch", "Outfield", "Facilities" ] ];
  my $line;
  my $err = 0;

  # print Dumper @menus;
  foreach my $m (@menus) {

    # print Dumper $m;
    my $lt = LeagueTable->new( -config => $config );
    $lt->set_division( $m->{csv_file} );
    eval {
      $lt->gather_data();
      my @rows = $lt->_get_all_week_data;

      # print Dumper @rows;
      next if !scalar @rows;
      my $formatted = [];
      $formatted = $self->format_rows( \@rows, $m->{menu_name} );
      push @$data, @$formatted;
      1;
    } || $self->logger->error($@);
  }
  my $csv   = Text::CSV->new();
  my $lines = [];
  foreach my $r (@$data) {
    my $s = $csv->combine(@$r);
    push @$lines, $csv->string;
  }

  my $q = $self->get_query;
  $line = $q->header(
    '-type'                => 'text/csv; name="ground_markings.csv"',
    '-Content-Disposition' => 'attachment; filename= "ground_markings.csv"'
    )
    . "\n"
    . join( "\n", @$lines ) . "\n";

  # print Dumper $line;
  return ( $err, $line );
}

sub format_rows {
  my ( $self, $rows, $name ) = @_;
  my $formatted = [];
  foreach my $r (@$rows) {
    my $odd   = 1;
    my $match = {};
    my $lines = $r->{LINES};
    my $week  = $r->{WEEK};
    foreach my $l (@$lines) {
      if ($odd) {
        $match = clone $l;
      }
      else {
        $match->{away_team} = $l->{team};
        push @$formatted,
          [
          $week,               $name,              $match->{team},
          $match->{away_team}, $match->{pitchmks}, $match->{groundmks},
          $match->{facilitiesmks}
          ];
      }
      $odd = $odd ? undef : 1;

      # print Dumper $l;
    }
  }
  return $formatted;
}

1;

