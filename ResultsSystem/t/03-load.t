#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use DateTime;

BEGIN {
  use_ok('ResultsSystem::Fixtures::Fixture') || print "Bail out!\n";
  use_ok('ResultsSystem::Fixtures::Set')     || print "Bail out!\n";
}

my $now = DateTime->new( day => 1, month => 7, year => 2014 );

my $set;
ok( $set = ResultsSystem::Fixtures::Set->new(), "Object created." );

for ( my $i = 0; $i < 2; $i++ ) {
  my $f;
  lives_ok(
    sub {
      $f = ResultsSystem::Fixtures::Fixture->new(
        week_commencing => $now,
        match_date      => $now->clone->add( days => 1 ),
        home            => 'Yorkshire' . $i,
        away            => 'Lancashire' . $i
      );
    },
    "Can create an object."
  );

  ok( $set->push_element($f), "Element pushed" );
}

is(
  $set . "",
  join( "\n",
    "ResultsSystem::Fixtures::Set with 2 elements",
    "  week_commencing: Tuesday 1 July 2014 match_date: Wednesday 2 July 2014 home: Yorkshire0 away: Lancashire0",
    "  week_commencing: Tuesday 1 July 2014 match_date: Wednesday 2 July 2014 home: Yorkshire1 away: Lancashire1"
  ),
  "Object stringifies correctly."
) || diag( $set . "\n" );

diag(
  "Testing ResultsSystem::Fixtures::Fixture $ResultsSystem::Fixtures::Fixture::VERSION, Perl $], $^X"
);

done_testing;

