use utf8;

package ResultsSystem::DB::SQLiteSchema::ResultSet;
use strict;
use warnings;
use Data::Dumper;
use Data::FormValidator;
use Carp;

use base 'DBIx::Class::ResultSet';

sub validator {
    my $self = shift;
    if ( !$self->{_validator_object} ) {
        $self->{_validator_object} = Data::FormValidator->new;
    }
    return $self->{_validator_object};
}

sub die_if_invalid {
    my ( $self, $got, $profile ) = @_;
    my $result = $self->validator->check( $got, $profile );
    croak "VALIDATION_FAILED "
      . Dumper( "Missing:", $result->missing, "Invalid:", $result->invalid )
      if !$result->success;
    return 1;
}

1;
