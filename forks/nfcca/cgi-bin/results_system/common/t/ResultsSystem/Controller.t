use strict;
use warnings;
use Test::More;

use_ok('ResultsSystem::Controller');

my $c;
ok( $c = ResultsSystem::Controller->new, 'Got an object' );
isa_ok( $c, 'ResultsSystem::Controller' );

done_testing;
