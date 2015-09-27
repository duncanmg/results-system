use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Text::CSV_XS;
use DateTime::Format::Natural;

use ResultsSystem::Fixtures::Parser;

use ResultsSystem::DB::SQLiteSchema;

my $file = shift @ARGV;

print $file."\n";;
die "File $file does not exist" if ! (-f $file);

my $csv = Text::CSV_XS->new;
my $dtf = DateTime::Format::Natural->new();

my $parser = ResultsSystem::Fixtures::Parser->new( source_file => $file, csv => $csv, datetime_natural=>$dtf );

$parser->parse_file();

print $parser->fixtures;

my $schema = ResultsSystem::DB::SQLiteSchema->connect('dbi:SQLite:rs.db');

my $it = $parser->fixtures->iterator;

print "\n";
print "\n";

my $hr = {};

while (my $fs = $it->()){
  my $fs_it = $fs->iterator;
  while (my $f = $fs_it->()){
     print $f->home."\n";
     $hr->{$f->home} = 1;
     $hr->{$f->away} = 1;
  }
}

my $id=0;
foreach my $k (sort keys %$hr ) {
  $schema->resultset('Team')->create( { id => $id, name => $k } );
  $hr->{$k} = $id++;
}

print Dumper $hr;

$it = $parser->fixtures->iterator;

$id = 0;
my $did = 0;
while (my $fs = $it->()){
  my $fs_it = $fs->iterator;
  while (my $f = $fs_it->()){
    $schema->resultset('Match')->create({ id => $id++, date => $f->week_commencing });
    $schema->resultset('MatchDetail')->create({ id => $did++, match_id => $id, team_id => $hr->{$f->home}, home_away => 'H' });
    $schema->resultset('MatchDetail')->create({ id => $did++, match_id => $id, team_id => $hr->{$f->away}, home_away => 'A' });
  }
}
