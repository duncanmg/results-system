use strict;
use warnings;

use DBIx::Class::Schema::Loader qw/ make_schema_at /;
    make_schema_at(
        'DB::RSSchema',
        { debug => 1,
          dump_directory => './lib',
        },
        [ 'dbi:SQLite:dbname=/home/duncan/git/results-system-v3/sqlite/rs.db',"","",
           # { loader_class => 'MyLoader' } # optionally
        ],
    );

