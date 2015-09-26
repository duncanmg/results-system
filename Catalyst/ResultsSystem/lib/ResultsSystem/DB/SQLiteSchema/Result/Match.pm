use utf8;
package ResultsSystem::DB::SQLiteSchema::Result::Match;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ResultsSystem::DB::SQLiteSchema::Result::Match

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<match>

=cut

__PACKAGE__->table("match");

=head1 ACCESSORS

=head2 id

  data_type: 'int'
  is_nullable: 1

=head2 date

  data_type: 'string'
  is_nullable: 1

=head2 division_id

  data_type: 'int'
  is_nullable: 1

=head2 played_yn

  data_type: 'string'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "int", is_nullable => 1 },
  "date",
  { data_type => "string", is_nullable => 1 },
  "division_id",
  { data_type => "int", is_nullable => 1 },
  "played_yn",
  { data_type => "string", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-19 15:21:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cCGPw4MjlDy7d0PjrUN/Aw

__PACKAGE__->has_many('match_details' => 'MatchDetail',
            { 'foreign.match_id' => 'self.id' } );

__PACKAGE__->has_many('team' => 'ResultsSystem::DB::SQLiteSchema::Team',
            { 'foreign.id' => 'self.team_id' } );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
