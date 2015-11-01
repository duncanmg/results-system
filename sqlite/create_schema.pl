use strict;
use warnings;
use Getopt::Long;

my $db_fullpath = "/home/duncan/results-system/sqlite/rs.db";
my $schema_fullpath = './lib';

GetOptions("db_fullpath=s" => \$db_fullpath, "schema_fullpath=s" => \$schema_fullpath);

use DBIx::Class::Schema::Loader qw/ make_schema_at /;
    make_schema_at(
        'ResultsSystem::DB::SQLiteSchema',
        { debug => 1,
          dump_directory => $schema_fullpath,
          components => 'Validation'
        },
        [ "dbi:SQLite:dbname=$db_fullpath","","",
           # { loader_class => 'MyLoader' } # optionally
        ],
    );

