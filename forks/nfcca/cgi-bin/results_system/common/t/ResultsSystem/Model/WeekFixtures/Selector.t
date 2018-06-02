use strict;
use warnings;
use Test::More;
use Helper qw/get_factory/;

use_ok('ResultsSystem::Model::WeekFixtures::Selector');

my $selector;
ok( $selector = get_factory()->get_week_fixtures_selector_model, "Got an object" );
isa_ok( $selector, 'ResultsSystem::Model::WeekFixtures::Selector' );

done_testing;
