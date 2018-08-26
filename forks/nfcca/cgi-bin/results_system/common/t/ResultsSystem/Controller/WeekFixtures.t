use strict;
use warnings;
use Test::More;
use Helper qw/get_factory/;

use_ok('ResultsSystem::Controller::WeekFixtures');

my $wf;
ok( $wf = get_factory()->get_week_fixtures_controller, 'Got an object' );
isa_ok( $wf, 'ResultsSystem::Controller::WeekFixtures' );

done_testing;

