use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;

use_ok('ResultsSystem::DB::SQLiteSchema');

my @connect_info = ("dbi:SQLite:dbname=/home/duncan/results-system/sqlite/rs.db","","");

# my $schema = MyApp::Schema->connect($dbi_dsn, $user, $pass);
my $schema = ResultsSystem::DB::SQLiteSchema->connect(@connect_info);
ok($schema,"Connected to ResultsSystem::DB::SQLiteSchema");

my $rs = $schema->resultset('Match');
ok($rs,"Got a result set for Match");

ok($rs->search(undef)->count, "Got at least 1 match");

my $min=$rs->search(undef)->get_column("id")->min();
ok(defined($min), "Min id is $min");

dies_ok(sub{$rs->create_or_update_week_results({not_id=>$min, home_runs_scored => 500});},
"Correctly died with missing id.") ;

throws_ok(sub{$rs->create_or_update_week_results({id=>$min, home_runs_scored => 500});},
qr/VALIDATION_FAILED/x, "Correctly died with missing mandatory field.") ;

done_testing;
