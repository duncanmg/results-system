use strict;
use warnings;
use Test::More;
use Test::Exception;
use Helper qw/get_config get_logger/;

use_ok('ResultsSystem::Model::LeagueTable');

ok(
  $ARGV[0] || $ENV{NFCCA_CONFIG},
  "Got a filename in ARGV. <"
    . ( $ARGV[0] || "" )
    . "> or NFCCA_CONFIG is set. <"
    . ( $ENV{NFCCA_CONFIG} || "" ) . ">"
) || die "Unable to continue.";
my $file = $ARGV[0] || $ENV{NFCCA_CONFIG};

my $config = get_config;

my $lt;
ok( $lt = ResultsSystem::Model::LeagueTable->new( -config => $config, -logger => get_logger() ),
  "Created a LeagueTable object." );

done_testing;
