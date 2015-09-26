use utf8;
package ResultsSystem::DB::SQLiteSchema::ResultSet::Match;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub all_matches_ordered {
    my ($self) = @_;

    return $self->search(
        {},
        { order_by => ['date'] },
    );
}

1;
