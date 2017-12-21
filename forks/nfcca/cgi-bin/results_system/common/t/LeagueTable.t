use strict;
use warnings;
use Test::More;
use Test::Exception;

use_ok('LeagueTable');
use_ok('ResultsConfiguration');

ok(
  $ARGV[0] || $ENV{NFCCA_CONFIG},
  "Got a filename in ARGV. <"
    . ( $ARGV[0] || "" )
    . "> or NFCCA_CONFIG is set. <"
    . ( $ENV{NFCCA_CONFIG} || "" ) . ">"
) || die "Unable to continue.";
my $file = $ARGV[0] || $ENV{NFCCA_CONFIG};

my $config;
ok( $config = ResultsConfiguration->new( -full_filename => $file ), "Object created." );
isa_ok( $config, 'ResultsConfiguration' );
ok( !$config->read_file, "Read file" );

my $lt;
ok( $lt = LeagueTable->new( -config => $config ), "Created a LeagueTable object." );

is( $lt->_sort_table, 1, "Returns an error because nothing is initialised." );

$lt->{AGGREGATED_DATA} = undef;
$lt->{TAGS}->{calculations}[0]{order_by}[0] = "average";
is( $lt->_sort_table, 1,
  "Returns an error because the configuration is ok but the data is just undefined." );

$lt->{AGGREGATED_DATA} = [];
is( $lt->_sort_table, 0,
  "Returns correctly because the configuration is ok and the data is just an empty array." );

$lt->{AGGREGATED_DATA} = [ { average => 1 }, { average => 2 } ];
is( $lt->_sort_table, 0,
  "Returns correctly because the configuration is ok and the data is a valid array of hash refs."
);
is( $lt->{SORTED_TABLE}->[0]->{average}, 2, "The data is sorted into descending order!" );
is( $lt->{SORTED_TABLE}->[1]->{average}, 1, "The data is sorted into descending order!" );

$lt->{AGGREGATED_DATA} = [ { average => 1 }, { average => 'nan' } ];
is( $lt->_sort_table, 1,
  "Returns lives but returns an error because the configuration is ok but one of the 'average' keys is a string."
);

$lt->{AGGREGATED_DATA} = [ { average => undef }, { average => 1 } ];
is( !$lt->_sort_table, 1,
  "Returns correctly because the configuration is ok but one of the 'average' keys is undefined, but this is sorted as a zero."
);
is( $lt->{SORTED_TABLE}->[0]->{average}, 1,     "The data is sorted into descending order!" );
is( $lt->{SORTED_TABLE}->[1]->{average}, undef, "The data is sorted into descending order!" );

done_testing;
