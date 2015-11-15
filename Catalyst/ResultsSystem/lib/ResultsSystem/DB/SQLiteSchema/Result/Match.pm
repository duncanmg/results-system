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

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Validation>

=back

=cut

__PACKAGE__->load_components("Validation");

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-01 12:18:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HWJTz+0Z1vzECRz7I3y++g

__PACKAGE__->has_many('match_details' => 'MatchDetail',
            { 'foreign.match_id' => 'self.id' } );

__PACKAGE__->has_many('team' => 'ResultsSystem::DB::SQLiteSchema::Team',
            { 'foreign.id' => 'self.team_id' } );

__PACKAGE__->set_primary_key('id');

__PACKAGE__->load_components(qw/ Validation/);

__PACKAGE__->validation(module => 'Data::FormValidator',
                        profile => { required => [ "id" ], optional => [ "date", "division_id", "played_yn"], 
                                     constraint_methods => { id => qr/^[0-9]+$/x, played_yn => qr/^[YN]$/x}, 
                                     field_filters => { played_yn => 'uc' }
                                   },
                        filter => 1,
                        auto => 1);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
