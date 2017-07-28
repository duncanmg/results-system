package LoadEnv;

use strict;
use warnings;

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
  my $FP;
  open( $FP, "<", "./env.ini" ) || die "Unable to open env.ini. " . $!;
  while ( my $line = <$FP> ) {
    if ( $line =~ m/^INC=/ ) {
      $line =~ s/INC=//;
      chomp $line;
      unshift @INC, $line;
    }

  }
  return close $FP;
}

1;
