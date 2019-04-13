use strict;
use warnings;
use Test::More;
use Test::Exception;
use Helper qw/ get_factory /;

use_ok('ResultsSystem::View::TablesIndex');

my $v;
ok( $v = get_factory->get_tables_index_view, "Got an object" );
isa_ok( $v, 'ResultsSystem::View::TablesIndex' );

# lives_ok( sub { $v->run( {} ) }, "run lives" );

done_testing;

