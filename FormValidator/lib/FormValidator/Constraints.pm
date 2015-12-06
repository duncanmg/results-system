package Constraints;

use strict;
use warnings;
use Data::Constraints;

sub match_pos_integer {
  my $v = shift;
  return $v =~ m/^\d+$/x;
}

sub match_integer {
return sub {
  my $v = shift;
  return $v =~ m/^-{0,1}\d+$/x;
};
}

sub match_pos_float {
return sub{
  my $v = shift;
  return $v =~ m/^\d+\.\d+$/x;
};
}

1;

