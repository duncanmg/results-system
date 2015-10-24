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
  is_nullable: 0

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
  { data_type => "int", is_nullable => 0 },
  "date",
  { data_type => "string", is_nullable => 1 },
  "division_id",
  { data_type => "int", is_nullable => 1 },
  "played_yn",
  { data_type => "string", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-10-24 19:13:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QIqFbl7Wtvr//CvOi+2Y7w

__PACKAGE__->has_many('match_details' => 'MatchDetail',
            { 'foreign.match_id' => 'self.id' } );

__PACKAGE__->has_many('team' => 'ResultsSystem::DB::SQLiteSchema::Team',
            { 'foreign.id' => 'self.team_id' } );

__PACKAGE__->set_primary_key('id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
