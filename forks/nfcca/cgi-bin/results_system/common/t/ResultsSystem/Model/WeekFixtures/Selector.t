use strict;
use warnings;
use Test::More;
use Test::Differences;
use Test::Exception;
use Test::MockObject;

use Helper qw/get_factory/;

use_ok('ResultsSystem::Model::WeekFixtures::Selector');

my $selector;
ok(
  $selector = get_factory()->get_week_fixtures_selector_model,
  "Got an object. Season=" . $selector->get_configuration->get_season
);
isa_ok( $selector, 'ResultsSystem::Model::WeekFixtures::Selector' );

dies_ok( sub { $selector->select( -division => 'Bad.csv', -week => '9-May' ) },
  "Dies with bad file" );

eq_or_diff( $selector->select( -division => 'U9N.csv', -week => '9-Jan' ),
  [], "Return empty array ref for rows when bad date" );

my $mock_week = Test::MockObject->new();
$mock_week->mock( 'set_division', sub { return 1; } );
$mock_week->mock( 'set_week',     sub { return 1; } );
$mock_week->mock( 'read_file',    sub { return 1; } );
$mock_week->mock( 'get_lines',    sub { return []; } );

my $mock_fixtures = Test::MockObject->new();
$mock_fixtures->mock( 'set_division',      sub { return 1; } );
$mock_fixtures->mock( 'set_week',          sub { return 1; } );
$mock_fixtures->mock( 'set_full_filename', sub { return 1; } );
$mock_fixtures->mock( 'read_file',         sub { return 1; } );
$mock_fixtures->mock( 'get_week_fixtures', sub { return []; } );

my $mock_adapter = Test::MockObject->new();
$mock_adapter->mock(
  'adapt',
  sub {
    [ map { $_->{added} = 1; $_ } @{ $_[1]->{-fixtures} } ];
  }
);

$selector->set_week_results($mock_week);

$selector->set_fixtures($mock_fixtures);

$selector->set_fixtures_adapter($mock_adapter);

eq_or_diff( $selector->select( -division => 'U9N.csv', -week => '8-May' ),
  [], "There aren't any fixtures or results so an empty array ref is returned." );

$mock_week->mock( 'get_lines',
  sub { return [ { a => 1, b => 2, c => 3 }, { a => 4, b => 5, c => 6 } ]; } );

eq_or_diff(
  $selector->select( -division => 'U9N.csv', -week => '8-May' ),
  [ { a => 1, b => 2, c => 3 }, { a => 4, b => 5, c => 6 } ],
  "There are some results, so they are returned."
);

$mock_fixtures->mock( 'get_week_fixtures',
  sub { return [ { d => 1, e => 2, f => 3 }, { d => 4, e => 5, f => 6 } ]; } );

eq_or_diff(
  $selector->select( -division => 'U9N.csv', -week => '8-May' ),
  [ { a => 1, b => 2, c => 3 }, { a => 4, b => 5, c => 6 } ],
  "There are some results and some fixtures, the results returned."
);

$mock_week->mock( 'get_lines', sub { return []; } );

eq_or_diff(
  $selector->select( -division => 'U9N.csv', -week => '8-May' ),
  [ { d => 1, e => 2, f => 3, added => 1 }, { d => 4, e => 5, f => 6, added => 1 } ],
  "There are only fixtures, so they are adapted and returned."
);

done_testing;
