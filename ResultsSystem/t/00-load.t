#!perl 
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;

BEGIN {
  use_ok('ResultsSystem::Fixtures::Parser') || print "Bail out!\n";
}

my $rs;

lives_ok( sub { $rs = ResultsSystem::Fixtures::Parser->new( source_file => 't/2012RD4NW.csv' ); },
  "Object created" );

lives_ok( sub { $rs->parse_file; }, "Fixtures parsed." );

my $fixtures = $rs->fixtures;
isa_ok( $fixtures, "ResultsSystem::Fixtures::Set" );

is( $fixtures->count, 18, "Got fixtures for 18 weeks." );

my $iter = $fixtures->iterator;
while ( my $i = $iter->() ) {
  is( $i->count, 4, "The individual weeks have 4 fixtures." );
  diag( $i->iterator->()->match_date );
}

# diag( $rs->fixtures."" );
diag(
  "Testing ResultsSystem::Fixtures::Parser $ResultsSystem::Fixtures::Parser::VERSION, Perl $], $^X"
);

done_testing;

