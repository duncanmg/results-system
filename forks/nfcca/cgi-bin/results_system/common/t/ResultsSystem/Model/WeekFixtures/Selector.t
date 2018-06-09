use strict;
use warnings;
use Test::More;
use Test::Differences;
use Test::Exception;
use Test::MockObject;

use Helper qw/get_factory/;

use_ok('ResultsSystem::Model::WeekFixtures::Selector');

my $selector;
ok( $selector = get_factory()->get_week_fixtures_selector_model, "Got an object" );
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

$selector->set_week_results($mock_week);

$selector->set_fixtures($mock_fixtures);

eq_or_diff( $selector->select( -division => 'U9N.csv', -week => '8-May' ), [] );

done_testing;
