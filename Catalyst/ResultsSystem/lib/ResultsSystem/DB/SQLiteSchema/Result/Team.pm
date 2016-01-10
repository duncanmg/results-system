use utf8;
package ResultsSystem::DB::SQLiteSchema::Result::Team;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ResultsSystem::DB::SQLiteSchema::Result::Team

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

=head1 TABLE: C<team>

=cut

__PACKAGE__->table("team");

=head1 ACCESSORS

=head2 id

  data_type: 'int'
  is_nullable: 1

=head2 name

  data_type: 'string'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "int", is_nullable => 1 },
  "name",
  { data_type => "string", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-01 12:18:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZHYWHd1qwpV0UtqeWfJcTw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;