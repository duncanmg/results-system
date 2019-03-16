
=head1 Admin::Command::season

Command to help set up the directories for the new season.

To display instructions on the command line:

perl admin2.pl help season

=cut

## no critic (NamingConventions::Capitalization NamingConventions::ProhibitAmbiguousName)

package Admin::Command::season;

use strict;
use warnings;
use File::Slurp qw/ slurp /;
use Admin -command;
use Carp;

use Data::Dumper;

use ResultsSystem::Configuration;

my $args = [qw(system year)];

=head2 App::Cmd Methods And Functions

=cut

=head3 usage_desc

=cut

sub usage_desc { return "admin2.pl season system year [-yu] [long options...]" }

=head3 abstract

=cut

sub abstract {
  return "Set up the new season.";
}

=head3 description

=cut

sub description {
  return (
    join(
      "\n",
      ( "Create the directories for the csv files, the results pages and the table pages. Update the config file.",
        "Two mandatory arguments.",
        "The full path and filename to the config file.",
        "The latest existing season. eg 2016 to set up 2017.",
      )
    )
  );
}

=head3 opt_spec

=cut

sub opt_spec {
  return (
    [ "dry-run|y",       "Dry run. Do not do anything!" ],
    [ "update-config|u", "Increment the season within the config file." ],
  );
}

=head3 validate_args

=cut

sub validate_args {
  my ( $self, $opt, $args2 ) = @_;

  # no args allowed but options!
  $self->usage_error("Two arguments required") if ( scalar(@$args2) != 2 );
  return 1;
}

=head3 execute

=cut

sub execute {
  my ( $self, $opt, $args2 ) = @_;
  my ( $conf_file, $year ) = @$args2;
  if ( !-f $conf_file ) {
    print "File $conf_file does not exist.\n";
    return;
  }
  my $conf = ResultsSystem::Configuration->new( -full_filename => $conf_file );
  if ( !$conf ) {
    print "Could not create ResultsSystem::Configuration object.\n";
    return;
  }
  $conf->read_file() && return;

  print "Season in config file is " . $conf->get_season . "\n";

  #if ( !$opt->{season} ) {
  #  $self->usage_error("A season must be provided.");
  #}

  $self->increment_season( $year, $conf, $conf_file, $opt );

  print "New season!\n";
  return 1;
}

=head2 Custom Methods And Functions

=cut

=head3 increment_html_directories

=cut

sub increment_html_directories {
  my ( $self, $config, $new_season, $dry_run ) = @_;

  # eg /home/duncan/results_system/forks/hcl/results_system/htdocs/custom/test/2012/tables
  foreach my $path (qw/ table_dir_full results_dir_full /) {
    my ( $stem, $current, $leaf ) =
      $config->get_path( "-" . $path => 'Y' ) =~ m~^(.*)/(\d{4})/([a-zA-Z]+)$~x;
    my $upper = "$stem/$new_season";
    my $lower = "$upper/$leaf";
    if ($dry_run) {
      my $msg = "About to create";
      print "$msg $upper\n";
      print "$msg $lower\n";
    }
    else {
      mkdir($upper) || do { print "Unable to create directory $upper\n" };
      mkdir($lower) || do { print "Unable to create directory $lower\n" };
    }
  }
  return 1;
}

=head3 increment_csv_directory

=cut

sub increment_csv_directory {
  my ( $self, $config, $new_season, $dry_run ) = @_;
  my $csvs = $config->get_path( "-csv_files" => "Y" );
  my $dir  = "$csvs/$new_season";
  if ($dry_run) {
    print "About to create $dir\n";
  }
  else {
    mkdir("$dir")
      || do { print "Unable to create directory $dir\n" };
  }
  return 1;
}

=head3 update_config_file

Changes every occurrence of $season in the configuration file with $new_season.

$new_season cannot be greater than the current calendar year.

=cut

sub update_config_file {
  my ( $self, $config_file, $season, $new_season, $dry_run ) = @_;
  my @lines = slurp $config_file;

  my ( undef, undef, undef, undef, undef, $year ) = localtime;
  $year += 1900;
  if ( $new_season > $year ) {
    print "The season cannot be incremented beyond this year ($year)\n";
    return;
  }

  foreach my $l (@lines) {
    $l =~ s/$season/$new_season/xg;
  }
  if ($dry_run) {
    print "New config file will look like this:\n" . join( "", @lines );
  }
  else {
    move( $config_file, "$config_file." . time() ) || croak;
    open( my $FP, '>', $config_file ) || croak;
    print $FP @lines;
    close $FP;
  }
  return 1;
}

=head3 increment_season

=cut

sub increment_season {
  my ( $self, $season, $config, $config_file, $opt ) = @_;

  my $new_season = $season + 1;

  $self->increment_html_directories( $config, $new_season, $opt->{dry_run} );

  $self->increment_csv_directory( $config, $new_season, $opt->{dry_run} );

  if ( $opt->{update_config} ) {
    $self->update_config_file( $config_file, $season, $new_season, $opt->{dry_run} );
  }
  return 1;

}

1;

