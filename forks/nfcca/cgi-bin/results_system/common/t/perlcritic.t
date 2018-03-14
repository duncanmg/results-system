
=head1 Description

Run perlcritic

  NFCCA_TESTDIR=`pwd` perl -I .  t/perlcritic.t

=cut

use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Find;
use Perl::Critic;
use File::Slurp qw/ slurp /;
use Data::Dumper;

my $file = shift @ARGV;

my $TESTDIR = $ENV{NFCCA_TESTDIR} || '.';

my @dirs = ($TESTDIR);

sub wanted {
  return 1 if $File::Find::dir =~ m/Dbix/;
  meets_policies($File::Find::name) if $_ =~ m/\.(pm|pl|t)$/;
}

sub meets_policies {
  my $full_file = shift;
  my ($is_t)    = $full_file =~ m/\.t$/;
  my $critic    = Perl::Critic->new(

    -severity => ( $is_t ? 5 : 3 ),
    -profile => $TESTDIR . '/t/.perlcriticrc',
  );
  my @violations = ();
  lives_ok( sub { @violations = $critic->critique($full_file) },
    "Perl::Critic ran for $full_file" );
  ok( !scalar(@violations), "$full_file meets policies" ) || diag(@violations);
  return 1;
}

if ($file) {
  meets_policies($file);
}
else {
  find( \&wanted, @dirs );
}

done_testing;

