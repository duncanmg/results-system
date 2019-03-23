use strict;
use warnings;
use Test::More;
use Helper qw/get_factory/;

use_ok('ResultsSystem::Controller::SaveResults');

my $c;
ok( $c = get_factory->get_save_results_controller, "Got an object" );
isa_ok( $c, 'ResultsSystem::Controller::SaveResults' );

done_testing;

