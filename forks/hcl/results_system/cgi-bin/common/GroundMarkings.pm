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
  my $data   = [ [ "Division", "Home", "Away", "Pitch", "Outfield", "Facilities" ] ];
  my $line;
  my $err = 0;

  # print Dumper @menus;
  foreach my $m (@menus) {

    # print Dumper $m;
    my $lt = LeagueTable->new( -config => $config );
    $lt->set_division( $m->{csv_file} );
    eval {
      $lt->gather_data();
      my $rows = $lt->_get_aggregated_data;
      next if !scalar @$rows;
      my $formatted = [];
      $formatted = $self->format_rows( $rows, $m->{menu_name} );
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
  $line = $q->header('text/csv') . "\n" . join( "\n", @$lines ) . "\n";

  # print Dumper $line;
  return ( $err, $line );
}

sub format_rows {
  my ( $self, $rows, $name ) = @_;
  my $odd       = 1;
  my $match     = {};
  my $formatted = [];
  foreach my $r (@$rows) {
    if ($odd) {
      $match = clone $r;
    }
    else {
      $match->{away_team} = $r->{team};
      push @$formatted,
        [
        $name,              $match->{team},      $match->{away_team},
        $match->{pitchmks}, $match->{groundmks}, $match->{facilitiesmks}
        ];
    }
    $odd = $odd ? undef : 1;
  }
  return $formatted;
}

1;

