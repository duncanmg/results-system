use strict;
use warnings;
use Test::More;
use Helper qw/get_factory/;

use_ok('ResultsSystem::Model::ResultsIndex');

my $ri;
$ri = ok( get_factory->get_results_index_model, "Got an object from factory" );
isa_ok( $ri, 'ResultsSystem::Model::ResultsIndex' );

my $index = $ri->run;
ok( scalar(@$index) > 0, "run() returned array ref with at least 1 row" );

done_testing;

