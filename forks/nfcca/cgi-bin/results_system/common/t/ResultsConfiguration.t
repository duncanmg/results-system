use strict;
use warnings;
use Test::More;
use Test::Exception;

use_ok('ResultsConfiguration');

ok( scalar(@ARGV), "Got a filename in ARGV. " . $ARGV[0] );

my $config;
ok( $config = ResultsConfiguration->new( -full_filename => shift(@ARGV) ), "Object created." );
isa_ok( $config, 'ResultsConfiguration' );

ok( !$config->read_file, "Read file" );

foreach my $p (
  qw/ -csv_files -log_dir -pwd_dir
  -cgi_dir -root -cgi-dir /
  )
{
  my $ff = $config->get_path( $p => "Y" ) || "";
  ok( ( -d $ff ), "$ff is a directory. " . $p );
}

foreach my $p (
  qw/ -csv_files -log_dir -pwd_dir -table_dir
  -htdocs -cgi_dir -root /
  )
{
  my $ff = $config->get_path( $p => "Y" )||"";
  ok( $ff, "$ff is set. " . $p );
}

done_testing;
