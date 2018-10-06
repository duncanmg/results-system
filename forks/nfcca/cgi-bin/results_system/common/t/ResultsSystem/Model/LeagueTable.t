use strict;
use warnings;
use Test::More;
use Test::Exception;
use Helper qw/get_config get_logger get_factory/;
use Test::Deep;

my $division = 'U9N.csv';

use_ok('ResultsSystem::Model::LeagueTable');

my $factory;
ok( $factory = get_factory, "Got a factory" );

ok( $factory->get_configuration->set_csv_file($division), 'Set csv file to ' . $division );

my $lt;
ok( $lt = $factory->get_league_table_model(), "Got an object" );
isa_ok( $lt, 'ResultsSystem::Model::LeagueTable' );

throws_ok( sub { $lt->get_division },
  qr/DIVISION_NOT_SET/, 'Division is not set automatically. (Perhaps it should be!)' );

ok( $lt->set_division($division), 'Set division' );
is( $lt->get_division, $division, 'Division ok' );

ok( $lt->_retrieve_week_results_for_division, "_retrieve_week_results_for_division" );

ok( scalar( @{ $lt->_get_week_results_list } ), "week_results_list has been populated" );

ok( !scalar( @{ $lt->_get_sorted_table } ), "_get_sorted_table returns empty list" );
ok( $lt->_retrieve_teams_for_division_from_fixtures,      '_retrieve_teams_for_division_from_fixtures' );

ok( scalar( @{ $lt->_get_sorted_table } ) > 0, "_get_sorted_table returns at least 1 team." );

ok( !scalar( @{ $lt->_get_aggregated_data } ), "_get_aggregated_data returns empty array ref" );
lives_ok( sub { $lt->_process_week_results_list }, "_process_week_results_list lived" );
ok( scalar( @{ $lt->_get_aggregated_data } ),
  "_get_aggregated_data array ref with at least 1 row" );

is( $lt->_get_order, "average", "Order returned by config is 'average'" );
$lt->_set_order(undef);

# is( $lt->_get_order, "total_pts", "Order defaults to 'total_pts'" );
$lt->_set_order("invalid");
is( $lt->_get_order,
  "totalpts", "Order cannot be set to anything other than 'average' or 'totalpts'" );
$lt->_set_order("average");
is( $lt->_get_order, "average", "average" );
$lt->_set_order("totalpts");
is( $lt->_get_order, "totalpts", "totalpts" );

$lt->_set_aggregated_data(
  [ { team => 'one', average => 2, totalpts => 1 },
    { team => 'two', average => 1, totalpts => 2 }
  ]
);
ok( $lt->_sort_table, "Sorted table" );
cmp_deeply(
  $lt->_get_sorted_table,
  [ { team => 'two', average => 1, totalpts => 2 },
    { team => 'one', average => 2, totalpts => 1 }
  ],
  "Table is sorted by descending totalpts"
);

$lt->_set_order("average");

$lt->_set_aggregated_data(
  [ { team => 'one', average => 2, totalpts => 7 },
    { team => 'two', average => 3, totalpts => 2 }
  ]
);
ok( $lt->_sort_table, "Sorted table" );
cmp_deeply(
  $lt->_get_sorted_table,
  [ { team => 'two', average => 3, totalpts => 2 },
    { team => 'one', average => 2, totalpts => 7 }
  ],
  "Table is sorted by descenfing average"
);

ok( scalar( @{ $lt->create_league_table } ) > 0,
  "create_league_table returned array ref with at least 1 row" );

done_testing;
