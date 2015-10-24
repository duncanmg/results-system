use utf8;

package ResultsSystem::DB::SQLiteSchema::ResultSet::Match;
use strict;
use warnings;
use Data::Dumper;

use base 'DBIx::Class::ResultSet';

=head2 all_matches_ordered

$self->all_matches_ordered()

=cut

sub all_matches_ordered {
    my ($self) = @_;

    return $self->search( {}, { order_by => [ 'date', 'id' ] }, );
}

=head2 matches_for_date_and_division_ordered

$self->matches_for_date_and_division_ordered( $date, $division_id );

=cut

sub matches_for_date_and_division_ordered {
    my ( $self, $date, $division_id ) = @_;
    my $params = { date => $date };
    $params->{division_id} = $division_id if $division_id;
    return $self->search( $params,
        { order_by => [ 'date', 'division_id', 'id' ] } );
}

=head2 create_or_update_week_results

=cut

sub create_or_update_week_results {
    my ( $self, $hr ) = @_;

    my $tx = sub {

        my $s = sub {
            my $stem = shift() . '_';
            my $out  = {};
            for my $k (qw/ result runs_scored wickets_lost comments /) {
                $out->{$k} = $hr->{ $stem . $k };
            }
            return $out;
        };

        my $match = $self->find( { id => $hr->{id} } );
        $match->update( { played_yn => $hr->{played} } );

        my $details = $self->related_resultset('match_details');

        my $h = $s->("home");
        $details->search( { match_id => $hr->{id}, team_id => $hr->{home} } )
          ->next->update($h);

        $h = $s->("away");
        $details->search( { match_id => $hr->{id}, team_id => $hr->{away} } )
          ->next->update($h);
    };

    $tx->();
}

1;
