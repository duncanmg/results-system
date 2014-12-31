#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;
use Test::MockObject;

BEGIN {
  use_ok('ResultsSystem::Fixtures::Set') || print "Bail out!\n";
}

my $f;

lives_ok(
  sub {
    $f = ResultsSystem::Fixtures::Set->new();
  },
  "Can create an object."
);

is( $f->count, 0, "Object has no elements." );

my $i = 0;
while ( $i < 10 ) {
  $f->push_element( Test::MockObject->new );
  $i++;
}

is( $f->count, 10, "Object has 10 elements." );

my $iter;
ok( $iter = $f->iterator, "Got an iterator." );

while ( $i > 0 ) {
  ok( $iter->(), "$i. Iterator returned a value." );
  $i--;
}
ok( !$iter->(), "Iterator returned undef." );

diag("Testing ResultsSystem::Fixtures::Set $ResultsSystem::Fixtures::Set::VERSION, Perl $], $^X");

done_testing;

