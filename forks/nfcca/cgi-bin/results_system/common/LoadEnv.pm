package LoadEnv;

use strict;
use warnings;
use Carp;
use Slurp;

=head2 run

This is designed to be run in a BEGIN block and to set up the paths in @INC.

  BEGIN {
    use LoadEnv;
    LoadEnv::run();
  }

It reads a text file in called env.in which must exist and must be in the current
directory. The file must contain zero or more lines containing the identifier INC=
and a path. 

  INC=/home/hantscl/perl5/lib/perl5/x86_64-linux-thread-multi
  INC=/home/hantscl/perl5/lib/perl5

=cut

sub run {
  my @lines = slurp("./env.ini");
  prepend_to_inc( \@lines );
  return 1;
}

=head2 prepend_to_inc

=cut

sub prepend_to_inc {
  my $lines = shift;
  foreach my $line (@$lines) {
    if ( $line =~ m/^INC=/x ) {
      $line =~ s/INC=//x;
      chomp $line;
      unshift @INC, $line;
    }
  }
  return 1;
}

1;
