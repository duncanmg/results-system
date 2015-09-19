use utf8;
package ResultsSystem::DB::SQLiteSchema::Result::Division;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ResultsSystem::DB::SQLiteSchema::Result::Division

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<division>

=cut

__PACKAGE__->table("division");

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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-19 15:21:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WZ4Rjpn0tvZ6In3/qVOAqQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
