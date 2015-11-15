use utf8;

package ResultsSystem::DB::SQLiteSchema::ResultSet::Match;
use strict;
use warnings;
use Data::Dumper;
use Try::Tiny;
use Data::FormValidator;

use base 'ResultsSystem::DB::SQLiteSchema::ResultSet';

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

This doesn't create, it only updates. It only updates
one match at a time.

It should be called update_week_result() or
just update_match().

=cut

sub create_or_update_week_results {
    my ( $self, $hr ) = @_;

    my $tx = sub {

        my $results =
          $self->die_if_invalid( $hr, { required => [qw/ id /] } );

        my $s = sub {
            my $stem = shift() . '_';
            my $out  = {};
            for my $k (qw/ result runs_scored wickets_lost comments /) {
                $out->{$k} = $hr->{ $stem . $k };
            }
            return $out;
        };

        die "Need an id for the match." if !defined $hr->{id};

        my $match = $self->find( { id => $hr->{id} } );
        die "No match found for id $hr->{id}" if !$match;

        try {
            $match->update( { played_yn => $hr->{played} } );
        }
        catch {
            die ("VALIDATION_FAILED "
              . Dumper( $match->validation_result->missing, $match->validation_result->invalid ))
              if defined $match->validation_result;
            die $_;
        };

        my $details = $match->related_resultset('match_details');

        my $h = $s->("home");
        $details->search( { home_away => 'H' } )
          ->next->update($h);

        $h = $s->("away");
        $details->search( { home_away => 'A' } )
          ->next->update($h);

    };

    $tx->();
}

1;
