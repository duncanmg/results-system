#! /usr/bin/perl

# ****************************************************************************
#
# Name: checkfixtures.pl
#
# Function: Check for common errors in the fixtures files. Are there the same number
#       of lines separators as week separator lines? Do all the teams play the same
#       number of matches?
#
# 1.0  30 Jun 07 - Initial version
# 1.1  23 Feb 08 - Patterns improved. POD added.
# 1.2  27 Apr 08 - main() added. Can now check a whole directory.
#
# ****************************************************************************

use strict;
use warnings;
use Check qw/ check/;
use Getopt::Long;

my $options = { count_games_played => 1 };
GetOptions( $options, 'count_games_played!' );

# print $ARGV[0] . "\n";

=head1 checkfixtures.pl

Script which checks for simple errors in the .csv files which contain the fixtures for a division. Any errors
found are sent to the standard output.

Details of the checks are in Check.pm.

perl checkfixtures.pl [ filename | dirname ]

Can accept an option which stops it checking whether all the teams in a division play the same number of
games.

 perl checkfixtures.pl --nocount_games_played 
     /home/duncan/git/results_system/forks/nfcca/results_system/fixtures/nfcca/2018/U9N.csv

=cut

=head2 main()

Accepts one argument which can be either a file or a directory.
If it is a directory then all the files in the directory are checked,
if not then only the one file is checked.

=cut

# ********************************************************
sub main {

  # ********************************************************
  my ( $file, $opts ) = @_;
  my $FP;
  my @file_list;
  my $err = 0;

  if ( -d $file ) {
    if ( opendir( $FP, $file ) ) {
      my @fl = readdir($FP);
      close $FP;
      foreach my $f (@fl) {
        if ( $f !~ m/\.csv$/x ) {
          next;
        }
        push @file_list, "$file/$f";
      }
    }
    else {
      print "Unable to open directory $file.\n";
      $err = 1;
    }
  }
  elsif ( -f $file ) {
    push @file_list, $file if ( $file =~ m/\.csv$/x );
  }
  else {
    print "$file does not exist.\n";
    $err = 1;
  }

  foreach my $f (@file_list) {
    if ( check( $f, $opts ) ) {
      print "not ok: $f\n";
      $err = 1;
    }
    else {
      print "ok: $f\n";
    }
  }

  return $err;
}

main( $ARGV[0], $options );

