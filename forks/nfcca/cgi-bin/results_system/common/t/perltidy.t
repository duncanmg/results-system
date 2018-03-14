
=head1 Description

Check the files are tidy.

  NFCCA_TESTDIR=`pwd` perl -I .  t/perltidy.t

=cut

use strict;
use warnings;

use Test::More;
use File::Find;
use Perl::Tidy;
use File::Slurp qw/ slurp /;
use Data::Dumper;

my $file = shift @ARGV;

my $TESTDIR = $ENV{NFCCA_TESTDIR} || '.';

my @dirs = ($TESTDIR);

my $perltidyrc = $TESTDIR . "/t/perltidyrc";

sub wanted {
  is_tidy($File::Find::name) if $_ =~ m/\.(pm|pl|t)$/;
}

sub is_tidy {
  my $full_file = shift;
  my @before    = slurp($full_file);
  my @after     = ();
  Perl::Tidy::perltidy( source => \@before, destination => \@after, perltidyrc => $perltidyrc );
  return is_deeply( \@before, \@after, "Before and after are the same for $full_file" );
}

if ($file) {
  is_tidy($file);
}
else {
  find( \&wanted, @dirs );
}

done_testing;

