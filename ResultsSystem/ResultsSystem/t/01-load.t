#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use DateTime;

BEGIN {
  use_ok('ResultsSystem::Fixture') || print "Bail out!\n";
}

my $now = DateTime->now;
my $f;

lives_ok(
  sub {
    $f = ResultsSystem::Fixture->new(
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

diag("Testing ResultsSystem::Fixture $ResultsSystem::Fixture::VERSION, Perl $], $^X");

done_testing;

