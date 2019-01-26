  package ResultsSystem::Model::LeagueTable;

  use strict;
  use warnings;
  use Carp;

  use List::MoreUtils qw / first_index any /;
  use Sort::Maker;
  use Data::Dumper;
  use Params::Validate qw/:all/;

  use ResultsSystem::Model;
  use ResultsSystem::Exception;

  use parent qw/ResultsSystem::Model/;

=head1 NAME

ResultsSystem::Model::LeagueTable

=cut

=head1 SYNOPSIS

  my $l = ResultsSystem::Model::LeagueTable->new(-logger => $logger, 
						 -fixture_list_model => $f,
						 -store_model => $store);
  $l->create_league_table;

=cut

=head1 DESCRIPTION

Returns an array ref of hash refs. Each hash ref represents the data for a team in the league table.

The table is based on the results for the teams in that division over the whole season.

If there aren't any results yet, the fixture list is interrogated for a list of teams
and that is returned instead.

Each hash ref will always contain the key "team". If the structure is based on results, each
hash ref will also contain keys such as "played", "won", "lost", "totalpts", "average".

Tables based on results will be sorted by descending average or descending totalpts as determined
by set_order().

Tables based on fixtures will be sorted by descending team name.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

This is the constructor for a LeagueTable object.

  my $l = ResultsSystem::Model::LeagueTable->new(-logger => $logger, 
						 -fixture_list_model => $f,
						 -store_model => $wdm);
=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->set_arguments( [qw/ logger fixture_list_model store_model/], $args );

    return $self;
  }

=head2 create_league_table

Returns a sorted array ref of hash refs.

L</_retrieve_week_results_for_division>

L</_retrieve_teams_for_division_from_fixtures>

L</_process_week_results_list>

L</_sort_table>

L</_get_sorted_table>

=cut

  #***************************************
  sub create_league_table {

    #***************************************
    my $self = shift;

    $self->_retrieve_week_results_for_division();

    if ( scalar( @{ $self->_get_week_results_list } ) ) {
      $self->_process_week_results_list;

      $self->_sort_table;

    }
    else {
      $self->_retrieve_teams_for_division_from_fixtures;
    }

    return $self->_get_sorted_table;
  }

=head2 set_order

Set the ordering of the table, "average" or "totalpts".

=cut

  sub set_order {
    my ( $self, $v ) = @_;
    $self->{order} = $v;
    return $self;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_week_results_list

Method which returns the list ref of WeekResults objects.

 $all_wd = $self->_get_week_results_list;

=cut

  #***************************************
  sub _get_week_results_list {

    #***************************************
    my $self = shift;
    return $self->{WEEKDATA} || [];
  }

=head2 _set_week_results_list

Method which sets the list of WeekResults objects.

 $self->_set_week_results_list($list_ref);

=cut

  #***************************************
  sub _set_week_results_list {

    #***************************************
    my ( $self, $v ) = validate_pos( @_, 1, { type => ARRAYREF } );
    $self->{WEEKDATA} = $v;
    return $self;
  }

=head2 _process_week_results_list

This loops through the WeekResults objects and creates a data structure for
the league table. The structure consists of an array of hash references.

Always returns 1.

  $lt->_process_week_results_list;

=cut

  #***************************************
  sub _process_week_results_list {

    #***************************************
    my $self   = shift;
    my @all_wd = @{ $self->_get_week_results_list };
    my @table  = ();

    @table = @{ $self->_build_unsorted_table( \@all_wd ) };

    @table = @{ $self->_calculate_average_points( \@table ) };

    $self->_set_aggregated_data( \@table );

    return 1;
  }

=head2 _build_unsorted_table

=cut

  sub _build_unsorted_table {
    my ( $self, $all_wd ) = validate_pos( @_, 1, { type => ARRAYREF } );
    my @table = ();

    # Loop through all the week results objects.
    foreach my $wd (@$all_wd) {

      $self->logger->debug( "Loop wd: " . $wd );

      my $lineno = 0;

      my $counter = 0;    # Guard against infinite loops.

      while ( $counter < 1000 ) {

        # The processing finishes when there are no more lines
        # or the team name is undefined.
        my $fields_hash_ref = $wd->get_line($lineno);
        last if !$fields_hash_ref;
        last if !$fields_hash_ref->{team};
        $self->logger->debug("Process line $lineno. $fields_hash_ref->{team}");

        $counter++;
        $lineno++;

        # Find the row in the table for the current team.
        my ( $i, $t );
        ( $t, $i ) = $self->_get_index_of_team_in_table( \@table, $fields_hash_ref );
        @table = @$t;

        # Skip if the match hasn't been played.
        next if $fields_hash_ref->{played} !~ m/Y/i;
        $self->logger->debug( Dumper "Match has been played.", $fields_hash_ref );

        $table[$i]->{played} += 1;

        $table[$i]->{won} += 1 if ( $fields_hash_ref->{result} =~ m/w/ix );

        $table[$i]->{lost} += 1 if ( $fields_hash_ref->{result} =~ m/l/ix );

        $table[$i]->{tied} += 1 if ( $fields_hash_ref->{result} =~ m/t/ix );

        # The rest of the fields are numeric so just add the new value to the previous value.
        foreach my $k (qw /resultpts battingpts bowlingpts penaltypts totalpts/) {
          $table[$i]->{$k} = ( $table[$i]->{$k} || 0 ) + ( $fields_hash_ref->{$k} || 0 );

        }

      }

    }
    return \@table;
  }

=head2 _calculate_average_points

=cut

  sub _calculate_average_points {
    my ( $self, $table ) = validate_pos( @_, 1, { type => ARRAYREF } );

    foreach my $t (@$table) {

      $t->{average} = 0;
      if ( ( $t->{played} || 0 ) > 0 ) {

        $t->{average} = sprintf( "%.2f", $t->{totalpts} / $t->{played} );

      }

    }
    return $table;
  }

=head2 _get_index_of_team_in_table

Finds the index of the team in the table. Adds the team to the table
if necessary.

( $table, $i ) = $self->_get_index_of_team_in_table($table, $fields_hash_ref);

=cut

  sub _get_index_of_team_in_table {
    my ( $self, $table, $fields_hash_ref ) = @_;

    my $i = first_index { $_->{team} eq $fields_hash_ref->{team} } @$table;

    # Create one if necessary
    if ( $i < 0 ) {
      my $t = $self->get_new_table_row;
      $t->{team} = $fields_hash_ref->{team};
      push @$table, $t;
      $i = scalar(@$table) - 1;
    }
    return ( $table, $i );
  }

=head2 get_new_table_row

=cut

  sub get_new_table_row {
    return {
      team         => "",
      played       => 0,
      won          => 0,
      tied         => 0,
      lost         => 0,
      performances => "",
      resultpts    => 0,
      battingpts   => 0,
      bowlingpts   => 0,
      penaltypts   => 0,
      totalpts     => 0,
      average      => 0
    };
  }

=head2 _get_aggregated_data

Method which returns a reference to the unsorted list of aggregated data.

 $aggregated_list_ref = $lt->_get_aggregated_data;
 print $aggregated_list_ref->[0]->{totalpts} . "\n";

=cut

  #***************************************
  sub _get_aggregated_data {

    #***************************************
    my $self = shift;
    return $self->{AGGREGATED_DATA} || [];
  }

=head2 _set_aggregated_data

=cut

  #***************************************
  sub _set_aggregated_data {

    #***************************************
    my ( $self, $v ) = @_;
    $self->{AGGREGATED_DATA} = $v;
    return $self;
  }

=head2 _sort_table

Method which sorts the aggregated data into descending order
by the total number of points or the average number of points.

The ordering is set by the value returned by get_order.
This can be "totalpts" or "average".

The default is "totalpts".

The sorted data is placed in a new list.

  $err = $lt->_sort_table;

=cut

  #***************************************
  sub _sort_table {

    #***************************************
    my $self = shift;
    my @sorted;

    my $table = $self->_get_aggregated_data;
    croak( ResultsSystem::Exception->new( 'NO_AGGREGATED_DATA', 'No aggregated data to sort' ) )
      if !$table;

    my $sorter = make_sorter( 'ST', 'descending', number => '$_->{' . $self->_get_order . '}' );
    croak( ResultsSystem::Exception->new( 'NO_SORTER', "Unable to create sorter. " . $@ ) )
      if !$sorter;

    local $@ = "";
    eval {
      @sorted = $sorter->(@$table);
      1;
    }
      || croak(
      ResultsSystem::Exception->new( 'BAD_SORT', "Unable to sort table. $@" . Dumper($table) ) );
    $self->{SORTED_TABLE} = \@sorted;

    $self->logger->debug(
      "Table sorted by " . $self->_get_order . " " . Dumper( $self->{SORTED_TABLE} ) );
    return 1;

  }

=head2 _get_order

Returns the sort order. Defaults to "totalpts";

Will only ever return "average" or "totalpts".

=cut

  sub _get_order {
    my ( $self, $v ) = @_;
    $self->set_order("totalpts") if ( ( $self->{order} || "" ) ne "average" );
    return $self->{order};
  }

=head2 _set_sorted_table

=cut

  #***************************************
  sub _set_sorted_table {

    #***************************************
    my $self = shift;
    $self->{SORTED_TABLE} = shift;
    return;
  }

=head2 _get_sorted_table

This method returns a reference to the table of sorted data.

 $sorted_ref = $lt->_get_sorted_table;
 print $sorted_ref->[0]->{team} . "\n";

=cut

  #***************************************
  sub _get_sorted_table {

    #***************************************
    my $self = shift;
    return $self->{SORTED_TABLE} || [];
  }

=head2 _retrieve_week_results_for_division

This retrieves the list of WekkResults objects for the division and
calls _set_week_results_list.

=cut

  #***************************************
  sub _retrieve_week_results_for_division {

    #***************************************
    my $self = shift;

    $self->_set_week_results_list( $self->get_store_model->get_all_week_results_for_division );

    return 1;
  }

=head2 _retrieve_teams_for_division_from_fixtures

This method retrieves the teams for the division 
from the fixture list and calls _set_sorted_table.

Assumes the list is pre-sorted by team name.

=cut

  #***************************************
  sub _retrieve_teams_for_division_from_fixtures {

    #***************************************
    my $self = shift;

    $self->logger->debug("Use teams in fixture list.");

    $self->_set_sorted_table( $self->get_fixture_list_model->get_all_teams );

    return 1;
  }

=head2 set_fixture_list_model

=cut

  sub set_fixture_list_model {
    my ( $self, $v ) = @_;
    $self->{fixtures} = $v;
    return $self;
  }

=head2 get_fixture_list_model

=cut

  sub get_fixture_list_model {
    my $self = shift;
    return $self->{fixtures};
  }

=head2 set_store_model

=cut

  sub set_store_model {
    my ( $self, $v ) = @_;
    $self->{store_model} = $v;
    return $self;
  }

=head2 get_store_model

Returns the Model::Store object.

=cut

  sub get_store_model {
    my $self = shift;
    return $self->{store_model};
  }

=head1 UML

=head2 Activity Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/activity_diagram_model_league_table.jpeg"
width="1000" height="500" alt="UML" /></p>

=end HTML

=cut

  1;

