use strict;
use warnings;
use Test::More;

use_ok('ResultsSystem::View');

my $v;
ok( $v = ResultsSystem::View->new(), "Got an object" );
isa_ok( $v, 'ResultsSystem::View' );

is( $v->encode_entities("Hi & there. | '"), 'Hi &amp; there. | &#x27;', "encode_entities" );

done_testing;

