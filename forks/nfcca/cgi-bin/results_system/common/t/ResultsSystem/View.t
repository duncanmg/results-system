use strict;
use warnings;
use Test::More;

use_ok('ResultsSystem::View');

my $v;
ok( $v = ResultsSystem::View->new(), "Got an object" );
isa_ok( $v, 'ResultsSystem::View' );

is( $v->encode_entities("Hi & there. | '"), 'Hi &amp; there. | &#x27;', "encode_entities" );

ok( !$v->get_capture_output, "Capture output not set" );
is( $v->get_captured_output, undef, "Captured output undefined" );

ok( $v->set_capture_output(1), "Capture the output" );

ok( $v->output_rendered("testing"), "output_rendered" );

is( $v->get_captured_output, "testing", "Captured output as expected" );

done_testing;

