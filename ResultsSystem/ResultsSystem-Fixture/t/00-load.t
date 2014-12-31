#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

use DateTime;

plan tests => 2;

BEGIN {
  use_ok('ResultsSystem::Fixture') || print "Bail out!\n";
}

lives_ok(
  sub {
    ResultsSystem::Fixture->new(
      week_commencing => DateTime->now,
      home            => 'Yorkshire',
      away            => 'Lancashire'
    );
  },
  "Can create an object."
);

diag("Testing ResultsSystem::Fixture $ResultsSystem::Fixture::VERSION, Perl $], $^X");
