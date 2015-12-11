package FormValidator::Constraints;

use strict;
use warnings;

# use Data::Constraints;
use Exporter qw/import/;

our @EXPORT_OK = qw/match_integer match_pos_integer match_pos_float/;

our %EXPORT_TAGS =
  ( all => [qw/match_integer match_pos_integer match_pos_float/] );

sub match_pos_integer {
    return sub {
        my $dfv = shift;
        my $v   = $dfv->get_current_constraint_value();
        return $v =~ m/^\d+$/x;
    };
}

sub match_integer {
    return sub {
        my $dfv = shift;
        my $v   = $dfv->get_current_constraint_value();
        return $v =~ m/^-{0,1}\d+$/x;
    };
}

sub match_pos_float {
    return sub {
        my $dfv = shift;
        my $v   = $dfv->get_current_constraint_value();
        return $v =~ m/^\d+\.\d+$/x;
    };
}

1;

