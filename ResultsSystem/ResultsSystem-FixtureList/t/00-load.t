#!perl 
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;

BEGIN {
  use_ok('ResultsSystem::FixtureList') || print "Bail out!\n";
}

my $rs;

lives_ok( sub { $rs = ResultsSystem::FixtureList->new( source_file => 't/2012RD4NW.csv' ); },
  "Object created" );

my $fixtures = [];
lives_ok( sub { $fixtures = $rs->parse_file; }, "Fixtures parsed." );

done_testing;

diag("Testing ResultsSystem::FixtureList $ResultsSystem::FixtureList::VERSION, Perl $], $^X");

