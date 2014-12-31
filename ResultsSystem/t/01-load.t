#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use DateTime;

BEGIN {
  use_ok('ResultsSystem::Fixtures::Fixture') || print "Bail out!\n";
}

my $now = DateTime->new( day => 1, month => 7, year => 2014 );
my $f;

lives_ok(
  sub {
    $f = ResultsSystem::Fixtures::Fixture->new(
      week_commencing => $now,
      match_date      => $now->clone->add( days => 1 ),
      home            => 'Yorkshire',
      away            => 'Lancashire'
    );
  },
  "Can create an object."
);

is( $f->week_commencing, $now,         "week_commencing" );
is( $f->home,            'Yorkshire',  "home" );
is( $f->away,            'Lancashire', "away" );
is( $f->match_date . "", $now->clone->add( days => 1 ) . "", "match_date" );

is(
  $f . "",
  'week_commencing: Tuesday 1 July 2014 match_date: Wednesday 2 July 2014 home: Yorkshire away: Lancashire',
  "Object stringifies correctly."
);

diag(
  "Testing ResultsSystem::Fixtures::Fixture $ResultsSystem::Fixtures::Fixture::VERSION, Perl $], $^X"
);

done_testing;

