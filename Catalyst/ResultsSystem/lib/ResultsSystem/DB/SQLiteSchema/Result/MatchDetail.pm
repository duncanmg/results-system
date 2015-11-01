use utf8;
package ResultsSystem::DB::SQLiteSchema::Result::MatchDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ResultsSystem::DB::SQLiteSchema::Result::MatchDetail

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Validation>

=back

=cut

__PACKAGE__->load_components("Validation");

=head1 TABLE: C<match_details>

=cut

__PACKAGE__->table("match_details");

=head1 ACCESSORS

=head2 id

  data_type: 'int'
  is_nullable: 0

=head2 match_id

  data_type: 'int'
  is_nullable: 0

=head2 home_away

  data_type: 'string'
  is_nullable: 1

=head2 team_id

  data_type: 'int'
  is_nullable: 0

=head2 result

  data_type: 'string'
  is_nullable: 1

=head2 runs_scored

  data_type: 'int'
  is_nullable: 1

=head2 wickets_lost

  data_type: 'int'
  is_nullable: 1

=head2 runs_conceded

  data_type: 'int'
  is_nullable: 1

=head2 wickets_taken

  data_type: 'int'
  is_nullable: 1

=head2 batting_points

  data_type: 'int'
  is_nullable: 1

=head2 bowling_points

  data_type: 'int'
  is_nullable: 1

=head2 result_points

  data_type: 'int'
  is_nullable: 1

=head2 penalty_points

  data_type: 'int'
  is_nullable: 1

=head2 total_points

  data_type: 'int'
  is_nullable: 1

=head2 comments

  data_type: 'string'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "int", is_nullable => 0 },
  "match_id",
  { data_type => "int", is_nullable => 0 },
  "home_away",
  { data_type => "string", is_nullable => 1 },
  "team_id",
  { data_type => "int", is_nullable => 0 },
  "result",
  { data_type => "string", is_nullable => 1 },
  "runs_scored",
  { data_type => "int", is_nullable => 1 },
  "wickets_lost",
  { data_type => "int", is_nullable => 1 },
  "runs_conceded",
  { data_type => "int", is_nullable => 1 },
  "wickets_taken",
  { data_type => "int", is_nullable => 1 },
  "batting_points",
  { data_type => "int", is_nullable => 1 },
  "bowling_points",
  { data_type => "int", is_nullable => 1 },
  "result_points",
  { data_type => "int", is_nullable => 1 },
  "penalty_points",
  { data_type => "int", is_nullable => 1 },
  "total_points",
  { data_type => "int", is_nullable => 1 },
  "comments",
  { data_type => "string", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-01 12:18:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9VKI3nnwUYFEiWehBOsrww

use overload '""' => sub { "match_id: " . ($_[0]->id||"") . ", team_id: " .
                           ($_[0]->team_id||"") . ", home_away: " . ($_[0]->home_away||"") . 
                           ", result: " . ($_[0]->result||"") . ", runs_scored: " . ($_[0]->runs_scored||"") }, fallback => 1;

__PACKAGE__->has_one('team' => 'Team',
            { 'foreign.id' => 'self.team_id' } );

__PACKAGE__->set_primary_key('id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
