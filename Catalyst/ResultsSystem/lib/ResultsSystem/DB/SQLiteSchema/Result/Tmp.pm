use utf8;
package ResultsSystem::DB::SQLiteSchema::Result::Tmp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ResultsSystem::DB::SQLiteSchema::Result::Tmp

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

=head1 TABLE: C<tmp>

=cut

__PACKAGE__->table("tmp");

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

=head2 home_team_id

  data_type: 'int'
  is_nullable: 1

=head2 away_team_id

  data_type: 'int'
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
  "home_team_id",
  { data_type => "int", is_nullable => 1 },
  "away_team_id",
  { data_type => "int", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-01 12:18:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O6t5JdsOfeOkUCnF+zcKdQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
