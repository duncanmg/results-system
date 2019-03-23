use strict;
use warnings;
use Test::More;
use Helper qw/ get_factory /;

use_ok('ResultsSystem::Model::Frame');

my ( $frame, $data );

ok( $frame = get_factory->get_frame_model, "Got an object" );
isa_ok( $frame, "ResultsSystem::Model::Frame" );

ok( $data = $frame->run, "run" );

is( ref($data), "HASH", "data is a hash ref" );

done_testing;

