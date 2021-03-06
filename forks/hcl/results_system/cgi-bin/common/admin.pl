#! /usr/bin/perl

use strict;
use warnings;
use Carp::Assert;
use CGI;
use ResultsConfiguration;
use File::Slurp qw/ slurp /;
use File::Copy;
use Data::Dumper;
use List::MoreUtils qw/ firstval /;
use Check;

use Template;

my $placeholders = {};

#*************************************************************************
sub main() {

  my $cgi = CGI->new();
  my $template = Template->new();

  my $params = $cgi->Vars;
  assert( $params->{system}, "Got a system parameter." );
  my $system = $params->{system};

  my $config_file = "../custom/$system/$system.ini";
  my $config = ResultsConfiguration->new( -full_filename => $config_file );

  $config->read_file;
  $placeholders->{system} = $system;
  $placeholders->{season} = $config->get_season;
  $placeholders->{menu_names} = [ $config->get_menu_names() ];

  print STDERR Dumper( $params );
  print STDERR "$params->{submit} XXXXXXXXXXXXXXXXXXXX\n";
  if ( $params->{submit} ) {
    
    print STDERR "load_csv_file: " . ( $params->{csv_file} ? 1 : 0 ) . "\n";
    if ( $params->{increment_season} ) {
      increment_season( $placeholders->{season}, $config, $config_file );
    }
    elsif ( $params->{csv_file} ) {
      print STDERR "load_csv_file() " . Dumper( $params->{csv_file} ) ;
      load_csv_file( $config, $params );
    }
    
    $config->read_file;
    $placeholders->{season} = $config->get_season;

  }

  $template->process( 'admin.tt', $placeholders );

}

#*************************************************************************
sub load_csv_file {
  my ( $config, $params ) = @_;

  my $menu_names = [ $config->get_menu_names ];

  my $target;
  foreach my $k ( keys  %$params ) {
    my ( $menu_name ) = $k =~ m/(^.*)_checkbox$/;
    next if ! $menu_name;
    $target = firstval { $_->{menu_name} eq $menu_name; } @$menu_names;
    last;
  }

  my $data = $params->{csv_file};
  print STDERR Dumper $data;

  my @lines = split( /\n/, $data );
  my $err = Check::check( $target->{csv_file}, \@lines );

  if ( ! $err ) {

    my $FP;
    my $path = $config->get_path( "-csv_files" => "Y" );
    my $filename = "$path/$target->{csv_file}";
    if ( -f $filename ) {
      copy( $filename, $filename . '.' . time() ) || die "Unable to copy $filename to " . $filename . '.' . time() . " " . $!;
    }

    open( $FP, '>', $filename ) || die "Unable to open $filename for writing. $!";
    print $FP $data;
    close $FP;

  }

}

#*************************************************************************
sub increment_season {
  my ( $season, $config, $config_file ) = @_;
  my $FP;

  my ( undef, undef, undef, undef, undef, $year ) = localtime;
  $year += 1900;
  if ( $season >= $year ) {
    $placeholders->{messages} .= "The season cannot be incremented beyond this year ($year)<br/>";
    return undef;
  }
  my $new_season = $season + 1;

  # eg /home/duncan/results_system/forks/hcl/results_system/htdocs/custom/test/2012/tables
  foreach my $path ( qw/ table_dir_full results_dir_full / ) {
    my ( $stem, $current, $leaf ) = $config->get_path( "-".$path => 'Y' ) =~ m~^(.*)/(\d{4})/([a-zA-Z]+)$~;
    mkdir( "$stem/$new_season" ) || do { $placeholders->{messages} .= "Unable to create directory $stem/$new_season" };
    mkdir( "$stem/$new_season/$leaf" ) || do { $placeholders->{messages} .= "Unable to create directory $stem/$new_season/$leaf" };
  }
 
  my $csvs = $config->get_path( "-csv_files" => "Y" );
  mkdir( "$csvs/$new_season" ) || do { $placeholders->{messages} .= "Unable to create directory $csvs/$new_season" };

  my @lines = slurp $config_file;
  foreach my $l ( @lines ) {
    $l =~ s/$season/$new_season/g;
  }
  move( $config_file, "$config_file." . time() ) || die;
  open( $FP, '>', $config_file ) || die;
  print $FP @lines;
  close $FP;
}

main();

