use strict;
use warnings;
use Test::More;
use Test::Differences;
use Test::Exception;
use Test::MockObject;

use Helper qw/get_factory get_example_csv_full_filename get_example_results_full_filename /;

use_ok('ResultsSystem::Model::WeekFixtures::Selector');

my ( $factory, $configuration, $selector );

# The same configuration will always be used whilst $factory remains in scope.
ok( $factory = get_factory(), "Got a factory" );
ok( $configuration = $factory->get_configuration, "Got the configuration" );

# This will execute without error, but the WeekFixtures and FixtureList objects
# won't have read their files.
ok(
  $selector = $factory->get_week_fixtures_selector_model,
  "Got an object. Season=" . $selector->get_configuration->get_season
);
isa_ok( $selector, 'ResultsSystem::Model::WeekFixtures::Selector' );

throws_ok( sub { $selector->select( -week => '9-May' ) },
  qr/FIXTURES_NOT_DEFINED/x,
  "Throws FIXTURES_NOT_DEFINED when fixtures object has not loaded file." );

# Set up the configuration and create a new Selector object.
ok( $configuration->set_csv_file('U9N.csv'), "set_csv_file" );

ok( $configuration->set_matchdate('9-May'), "set_matchdate" );

ok(
  $selector = $factory->get_week_fixtures_selector_model,
  "Got an object. Season=" . $selector->get_configuration->get_season
);

lives_ok( sub { $selector->select( -week => '9-May' ) },
  "Lives now that FixturesList and WeekReasults::Reader have been loaded correctly." );

eq_or_diff( $selector->select( -week => '9-Jan' ),
  [], "Return empty array ref for rows when no fixtures or results for date." );

my $mock_week_results = Test::MockObject->new();
$mock_week_results->mock( 'get_lines', sub { return []; } );

my $mock_fixtures = Test::MockObject->new();
$mock_fixtures->mock( 'get_week_fixtures', sub { return []; } );

my $mock_adapter = Test::MockObject->new();
$mock_adapter->mock(
  'adapt',
  sub {
    [ map { $_->{added} = 1; $_ } @{ $_[1]->{-fixtures} } ];
  }
);

# **********************

$selector->set_week_results($mock_week_results);

$selector->set_fixtures($mock_fixtures);

$selector->set_fixtures_adapter($mock_adapter);

eq_or_diff( $selector->select( -week => '8-May' ),
  [], "There aren't any fixtures or results so an empty array ref is returned." );

# **********************

$mock_week_results->mock( 'get_lines',
  sub { return [ { a => 1, b => 2, c => 3 }, { a => 4, b => 5, c => 6 } ]; } );

eq_or_diff(
  $selector->select( -week => '8-May' ),
  [ { a => 1, b => 2, c => 3 }, { a => 4, b => 5, c => 6 } ],
  "There are some results, so they are returned."
);

# **********************

$mock_fixtures->mock( 'get_week_fixtures',
  sub { return [ { d => 1, e => 2, f => 3 }, { d => 4, e => 5, f => 6 } ]; } );

eq_or_diff(
  $selector->select( -week => '8-May' ),
  [ { a => 1, b => 2, c => 3 }, { a => 4, b => 5, c => 6 } ],
  "There are some results and some fixtures, the results returned."
);

# **********************

$mock_week_results->mock( 'get_lines', sub { return []; } );

eq_or_diff(
  $selector->select( -week => '8-May' ),
  [ { d => 1, e => 2, f => 3, added => 1 }, { d => 4, e => 5, f => 6, added => 1 } ],
  "There are only fixtures, so they are adapted and returned."
);
#
done_testing;
