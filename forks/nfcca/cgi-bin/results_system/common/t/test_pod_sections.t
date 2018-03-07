use strict;
use warnings;
use Data::Dumper;
use List::MoreUtils qw/ first_index /;

use Test::More;

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

sub test_pod_sections {
  my $hr = shift;

  # diag(Dumper $hr);
  #
  my @lines = slurp $hr->{ff};

  my @head1_sections = (
    "NAME",                      "SYNOPSIS",
    "DESCRIPTION",               "INHERITS FROM",
    'EXTERNAL \(PUBLIC\) METHODS', 'INTERNAL \(PRIVATE\) METHODS'
  );

  my $i = -100;
  foreach my $s (@head1_sections) {
    my $first = first_index { $_ =~ m/^\s*=head1\s$s/ } @lines;
    ok( $first >= 0, "Found $s in $hr->{ff}" );
    ok( $first > $i, "Heading $s is in the correct order $hr->{ff}" );
    $i = $first;
  }

}

find( \&find_modules, @dirs );

ok( scalar(@$modules_list), "Found some modules." );

foreach my $m (@$modules_list) {
  test_pod_sections($m);
}

done_testing;
