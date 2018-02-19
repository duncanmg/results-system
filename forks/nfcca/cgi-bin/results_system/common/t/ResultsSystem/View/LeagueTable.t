use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;

use Data::Dumper;
use Clone qw/clone/;

use_ok('ResultsSystem::View::LeagueTable');
use_ok('ResultsSystem');

#ok(
#  $ARGV[0] || $ENV{NFCCA_CONFIG},
#  "Got a filename in ARGV. <"
#    . ( $ARGV[0] || "" )
#    . "> or NFCCA_CONFIG is set. <"
#    . ( $ENV{NFCCA_CONFIG} || "" ) . ">"
#) || die "Unable to continue.";
#my $file = $ARGV[0] || $ENV{NFCCA_CONFIG};

my ( $rs, $f, $lt );

ok( $rs = ResultsSystem->new, "Created object" );
isa_ok( $rs, 'ResultsSystem' );

ok( $rs->get_starter->start('nfcca'), "Started system" );

ok( $f = $rs->get_factory, "Created factory" );
isa_ok( $f, 'ResultsSystem::Factory' );

ok( $lt = $f->get_league_table_view, "Got LeagueTable" );
isa_ok( $lt, 'ResultsSystem::View::LeagueTable' );

my $expected = [
  { team         => 'A',
    'played'     => 3,
    'won'        => 2,
    'tied'       => 1,
    'lost'       => 0,
    'battingpts' => 10,
    'bowlingpts' => 5,
    'penaltypts' => 1,
    'totalpts'   => 20
  },
  { team         => 'b',
    'played'     => 4,
    'won'        => 3,
    'tied'       => 1,
    'lost'       => 0,
    'battingpts' => 11,
    'bowlingpts' => 6,
    'penaltypts' => 0,
    'totalpts'   => 15
  },
];

$lt->run({-data=>{ rows => $expected, division => 'U9N.csv'}});

# ok( $lt->set_division('U9N.csv'), "Set division" );
# is( $lt->get_division, 'U9N.csv', "Get division" );
#
# my $num_files = scalar( @{ $lt->_get_all_week_files } );
# ok( $num_files, "Got at least one data file " . $num_files );
#
# ok( $lt->gather_data, "gather_data" );
#
# is( scalar( @{ $lt->{WEEKDATA} } ),
#   $num_files, "Got a week data object for each week data file." );
#
# ok( $lt->_process_data, "_process_data" );
#
# my $data = $lt->_get_aggregated_data;
# is( ref($data), "ARRAY", "_get_aggregated_data returns an array ref" );
#
# my $expected_keys = 11;
# foreach my $d (@$data) {
#   is( ref($d), "HASH", "It is an array ref of hash refs" );
#   my $num_keys = keys(%$d);
#   is( $num_keys, $expected_keys, "It has the correct number of keys" ) || diag( Dumper $d);
# }
#
# ok( $lt->_sort_table, "Sort_table" );
#
# my $sorted_table = [];
# ok( $sorted_table = $lt->_get_sorted_table, "_get_sorted_table" );
# ok( scalar(@$sorted_table) > 1, "Sorted table has at least 2 rows" )
#   || diag( Dumper $sorted_table);
#
# my $lastpts = 999999;
# foreach my $l (@$sorted_table) {
#   ok( $l->{totalpts} <= $lastpts,
#     "Table is in descending order by total points. " . $l->{totalpts} );
#   $lastpts = $l->{totalpts};
# }
#
# #++++++++++++++++++++++++++++++++++
#
# my $old_table = clone $sorted_table;
#
# isa_ok( $lt, 'ResultsSystem::Model::LeagueTable' );
#
# ok( $lt->set_division('U9N.csv'), "Set division" );
# is( $lt->get_division, 'U9N.csv', "Get division" );
# my $data = $lt->create_league_table;
# is_deeply($data, $old_table, "Get the same table when I run it all at once");

done_testing;
