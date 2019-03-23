use strict;
use warnings;
use Test::More;

use_ok('ResultsSystem::Controller');

my $c;
ok( $c = ResultsSystem::Controller->new, 'Got an object' );
isa_ok( $c, 'ResultsSystem::Controller' );

ok( $c = ResultsSystem::Controller->new, "Got an object" );
isa_ok( $c, 'ResultsSystem::Controller' );

# Ignoring types! These are objects.
my $methods = [
  { setter => 'set_logger',        getter => 'logger',            value => 1 },
  { setter => 'set_configuration', getter => 'get_configuration', value => 2 },

];

foreach my $m (@$methods) {
  my ( $s, $g, $v ) = ( $m->{setter}, $m->{getter}, $m->{value} );
  ok( $c->$s($v), "Set $m->{setter}" );
  is( $c->$g, $v, "Get $m->{getter}" );
}

ok( $c->set_arguments( ['logger'], { -logger => 20 } ), "set_arguments" );
is( $c->logger, 20, "set_arguments has set logger" );

done_testing;
