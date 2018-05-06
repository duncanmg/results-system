use strict;
use warnings;
use Test::More;
use Test::Exception;

use_ok('ResultsSystem::Model');

my $m;
ok( $m = ResultsSystem::Model->new(), "Got an object" );
isa_ok( $m, 'ResultsSystem::Model' );

lives_ok(
  sub { $m->set_arguments( [qw/ banana apple /], {} ) },
  "Do not call non-existent methods if key is not set."
);

throws_ok( sub { $m->set_arguments( [qw/ banana apple /], { -apple => 1 } ) },
  qr/apple/, "Call non-existent methods if key is set." );

done_testing;

