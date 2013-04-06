#! /usr/bin/perl

=head1 Name

results_system.pl

=cut

=head1 Description

The script is part of the Results System and is designed to be called from a browser. It is most commonly
be called using GET parameters.

Examples:

/cgi-bin/results_system/dev/common/results_system.pl?page=frame&system=sehca

/cgi-bin/results_system/dev/common/results_system.pl?system=sehca&page=results_index

/cgi-bin/results_system/dev/common/results_system.pl?system=sehca&page=tables_index

=over 5

=item * system

The results system which is to be called. The system can support several independent systems within the same directory structure
and using the same code base. eg HCL for Hampshire Cricket League and SEHCA for South East Hampshire Cricket Association.

This parameter is mandatory.

=item * page

The HTML page which the script should output. This parameter is mandatory.

=over 5

=item * results_index

=item * tables_index

=item * frame

=item * menu

=item * week_fixtures

=item * week_results

=item * save_results

=item * blank

=back

=back

=cut

use strict;
use warnings;

use CGI;
use Slurp;

use Fcutils2;

use Menu;
use WeekFixtures;
use LeagueTable;
use ResultsIndex;
use TablesIndex;

=head1 Functions

=cut

=head2 output_frame

Write the HTML for a frame based on common/results.htm in the htdocs
directory to the standard output.

It changes the paths and the system information, but nothing else.

=cut

# ******************************************************
# This function reads the frame page, results.htm. It substitutes
# in the correct path and system information for the pages and
# then sends it to the output. It give the frame an expiry time of
# two days.
# ******************************************************
sub output_frame(%) {
# ******************************************************
  my %args = ( @_ );
  my $q = $args{-query};
  my $c = $args{-config};
  my $u = $args{-util};
  my $err = 0;
  my $line;
  my @file_lines;
  
  my $root = $c->get_path( -root => "Y" );
 
  my $dir = $c->get_path( -htdocs_full => 'Y' );
  my $ff = "$dir/common/results.htm";
  
  if ( ! -f $ff ) {
    $u->eAdd( "$ff does not exist.", 5 );
    $err = 1;
  }
  
  my $cgi_path_full = $c->get_path( "-cgi-dir_full" => "Y" );
  my $cgi_path = $c->get_path( "-cgi-dir" => "Y" );
  $cgi_path_full = "$cgi_path_full/common";
  if ( ! -d "$cgi_path_full" ) {
    $u->eAdd( "output_frame() $cgi_path_full does not exist.", 5 );
    $err = 1;
  }
  
  if ( $err == 0 ) {
    @file_lines = slurp( $ff );
    $u->eAdd( scalar( @file_lines ) . " lines read from $ff", 1 );
    $cgi_path = $cgi_path . "/common/results_system.pl?system=" . $q->param("system") . "&page=";
    foreach my $f ( @file_lines ) {
      my $p = "menu";
      $f =~ s/MENU_PAGE/$cgi_path$p/;
      $p = "blank";
      $f =~ s/BLANK_PAGE/$cgi_path$p/;
      $p = $c->get_descriptors( title => "Y" );
      $f =~ s/TITLE/$cgi_path$p/;
      $line = $line . $f;
    }
  }
  
  print $q->header( -expires => "+5m" );
  print $line;
  # $u->eAdd( $line, 1 );
  return $err;  
}

=head2 output_page

Write the HTML for the page to the standard output.

=cut

# ******************************************************
sub output_page(%) {
# ******************************************************
  my %args = ( @_ );
  my $q = $args{-query};
  my $c = $args{-config};
  my $u = $args{-util};
  my $page = $args{-page} || "";
  my $err = 0;
  my $line;
  
  print $q->header( -expires => "+1m" );
  my @styles = $c->get_stylesheets;
  print $q->start_html( -title => "Results System: " . $page, -style => $c->get_path( -htdocs => "Y" ) . "/custom/" . $styles[0] );
  $u->eAdd( "page=$page", 1 );
  
  eval {
  
    if ( $page eq "menu" ) {
  
      my $p = Menu->new( -query => $q, -config => $c, -error => $u->eGetError );
      print $p->output_html;
    
    }

    elsif ( $page eq "week_fixtures" ) {
   
      my $p = WeekFixtures->new( -query => $q, -config => $c, -error => $u->eGetError );
      print $p->output_html( -form => "Y" );
      
    }
  
    elsif ( $page eq "week_results" ) {
   
      my $p = WeekFixtures->new( -query => $q, -config => $c, -error => $u->eGetError );
      print $p->output_html( );
      
    }
  
    elsif ( $page eq "save_results" ) {
   
      my $p = WeekFixtures->new( -query => $q, -config => $c, -error => $u->eGetError );
      ( $err, $line ) = $p->save_results( -save_html => "Y" );
      print $line;
      
      if ( $err == 0 ) {
        my $l = LeagueTable->new( -query => $q, -config => $c, -error => $u->eGetError );
        $err = $l->create_league_table_file;
        $u->eAdd( "create_league_table_file() returned err=$err", 1 );
      }
      
    }
  
    elsif ( $page eq "results_index" ) {
   
      my $p = ResultsIndex->new( -query => $q, -config => $c, -error => $u->eGetError );
      ( $err, $line ) = $p->output_html;
      print $line;
      
    }
  
    elsif ( $page eq "tables_index" ) {
   
      my $p = TablesIndex->new( -query => $q, -config => $c, -error => $u->eGetError );
      ( $err, $line ) = $p->output_html;
      print $line;
      
    }

    elsif ( $page eq "blank" ) {
      $u->eAdd( "Blank page called", 1 );
    }

    else {
      $u->eAdd( "Page parameter not recognised. " . $page, 2 );
    }
 
  };
  if ( $@ ) {
    $u->eAdd( $@, 5 );
    $err = 1;
  }
  
  # print "err=" . $err . " " . localtime;
  print $q->end_html . "\n";

  return $err;
}

# ******************************************************
sub main(;) {
# ******************************************************
  my $q = CGI->new();
  my $err = 0;
  my $LOG;
  my $log_file = "results_system";
  my $log_path = "/usr/home/sehca/public_html/sehca_logs";
  my $c;
  # my $line;

  map { $q->param( -name => $_, -value => "" ) if ! $q->param( $_ ) } ( "system", "matchdate", "page", "division", "user" );
  
  my $u = Fcutils2->new( -append_to_logfile => 'Y', -auto_clean => 'Y' );

  my $system = $q->param( "system" );
  my $page = $q->param( "page" );

  local $@;
  eval {
    my $f = $system ? "../custom/$system/$system.ini" : "";
    $u->eAdd( "Configuration file <$f> for system <$system>.", 1 );
    $c = ResultsConfiguration->new( -full_filename => $f, -error => $u->eGetError );
    if ( ! $c ) {
      $err = 1;
      $u->eAdd( $ResultsConfiguration::create_errmsg, 5 );
    }
    $err = $c->read_file if ! $err;
    if ( $err == 0 ) {
      $log_path = $c->get_path( -log_dir => "Y" );
      $log_file = $c->get_log_stem( $system );
    }
  };
  if ( $@ ) {
    print STDERR $@ . "\n";
    $u->eAdd( $@, 5 );
    $err = 1;
  }
  
  if ( $err == 0 ) {
    $err = $u->SetLogDir( $log_path );
  }
  if ( $err == 0 ) {
    $u->set_lock_dir( $log_path );
  }
  
  if ( $err == 0 ) {
    $err = $u->OpenLockFile( $log_file );
  }
  if ( $err == 0 ) {
    ( $err, $LOG ) = $u->OpenLogFile( $log_file );
  }
  if ( $err != 0 ) {
    print STDERR $u->eDump;
    print "<p>". $u->eDump . "</p>\n";
    return $err;
  }  
  
  $u->eAdd( "system=$system page=$page", 2 );
  $u->eAdd( "division=" . $q->param( "division" ) . " matchdate=" 
    . $q->param( "matchdate" ) . " user=" . $q->param( "user" ), 2 );
  
  if ( $page !~ m/frame/i ) {
    $err = output_page( -query => $q, -config => $c, -util => $u, -page => $page );
  }
  else {
    local $@;
    eval {
      $err = output_frame( -query => $q, -config => $c, -util => $u, -page => $page );
    };
    if ( $@ ) {
      $u->eAdd( $@, 5 );
      $err = 1;
    }
  }
  my $dbg = $c->get_default_debug_level if $c;
  $u->eSetMinDebug( $dbg );
  print $LOG $u->eDump();  
  $u->CloseLogFile( $LOG, $err );
  $u->CloseLockFile;

  return $err;  
}

eval {  main() } if ! caller;
print "<p>" . $@ . "</p>\n" if $@;

1;