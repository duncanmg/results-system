use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Pod::Coverage;

use File::Find;
use Slurp;

my @dirs         = qw/ ResultsSystem /;
my $modules_list = [];

sub find_modules {
  my $ff = $File::Find::name;

  # print $ff . "\n";
  if ( $ff =~ m/^.*\.pm$/ ) {
    my $tf = $ff;
    $tf =~ s/^.*ResultsSystem\//ResultsSystem\//;
    $tf =~ s/^(.*)\.pm$/$1.t/;
    push @$modules_list, { ff => $ff, tf => 't/' . $tf };
  }
}

sub test_pod_coverage {
  my $hr = shift;

  # diag(Dumper $hr);
  #
  my @lines = slurp $hr->{ff};
  my ($package) = grep { $_ =~ m/^\s*package\s+/ } @lines;
  $package =~ s/^\s*package\s+(\S+)\s*;.*$/$1/;
  chomp $package;
  pod_coverage_ok($package) || diag( $hr->{ff} );

}

find( \&find_modules, @dirs );

ok( scalar(@$modules_list), "Found some modules." );

foreach my $m (@$modules_list) {
  test_pod_coverage($m);
}

done_testing;
