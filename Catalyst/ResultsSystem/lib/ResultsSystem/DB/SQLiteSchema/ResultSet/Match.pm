use utf8;
package ResultsSystem::DB::SQLiteSchema::ResultSet::Match;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head2 all_matches_ordered

$self->all_matches_ordered()

=cut

sub all_matches_ordered {
    my ($self) = @_;

    return $self->search(
        {},
        { order_by => ['date', 'id'] },
    );
}

=head2 matches_for_date_and_division_ordered

$self->matches_for_date_and_division_ordered( $date, $division_id );

=cut

sub matches_for_date_and_division_ordered {
    my ($self, $date, $division_id) = @_;
    my $params = { date => $date };
    $params->{division_id} = $division_id if $division_id;
    return $self->search($params,{order_by => ['date','division_id','id']});
}

1;
