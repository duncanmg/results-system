use strict;
use warnings;
use Data::Dumper;

use Test::More;

use File::Find;
use Slurp;

my @dirs         = qw/ ResultsSystem /;
my $modules_list = [];

sub find_modules {
  my $ff = $File::Find::name;
  print $ff . "\n";
  if ( $ff =~ m/^.*\.pm$/ ) {
    my $tf = $ff;
    $tf =~ s/^.*ResultsSystem\//ResultsSystem\//;
    $tf =~ s/^(.*)\.pm$/$1.t/;
    push @$modules_list, { ff => $ff, tf => 't/' . $tf };
  }
}

sub find_test_script {
  my $hr = shift;

  # diag(Dumper $hr);
  ok( ( -f $hr->{tf} ), "Found test script for $hr->{ff}" )
    || diag("Could not find test script $hr->{tf}");

  if ( -f $hr->{tf} ) {
    my @lines = slurp $hr->{tf};
    my $f     = $hr->{tf};
    $f =~ s/^t\/(.*)\.t$/$1/;
    $f =~ s/\//::/g;
    my $pattern = qr/use_ok\s*\(\s*["']$f["'].*\)/;
    ok( ( grep { $_ =~ m/$pattern/ } @lines ), "Script $hr->{tf} uses $f" );
  }

}

find( \&find_modules, @dirs );

ok( scalar(@$modules_list), "Found some modules." );

foreach my $m (@$modules_list) {
  find_test_script($m);
}

done_testing;
