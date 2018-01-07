#!/usr/bin/perl

BEGIN {
  use LoadEnv;
  LoadEnv::run();
}

# use local::lib;

use strict;
use warnings;
use CGI;
use Data::Dumper;

use ResultsConfiguration;
use Fcutils2;
use Fixtures;

my $logger;

=head1 menu_js.pl

=cut

=head2 menu

Returns a string containing the javascript for two arrays: menu_names and csv_files.

  if ( typeof( menu_names ) == "undefined" ) { menu_names = new Array(); }
  if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }
  
  menu_names.push( "U9N" );
  csv_files.push( "U9N.csv" );
  
  menu_names.push( "U9S" );
  csv_files.push( "U9S.csv" );

=cut

# *********************************************
sub menu {

  # *********************************************
  my %args = (@_);
  my $c    = $args{-config};
  my $q    = $args{-query};
  my $u    = $args{-util};
  my $line;

  my @x = $c->get_menu_names;

  $line = "if ( typeof( menu_names ) == \"undefined\" ) { menu_names = new Array(); }\n";

  # print "if ( typeof( menu_names ) == null ) { menu_names = new Array(); }\n";

  $line = $line . "if ( typeof( csv_files ) == \"undefined\" ) { csv_files = new Array(); }\n\n";

  foreach my $x (@x) {

    $line = $line . "menu_names.push( \"" . $x->{menu_name} . "\" );\n";
    $line = $line . "csv_files.push( \"" . $x->{csv_file} . "\" );\n\n";

  }

  # print "alert('Bang!');";
  print $line;

  # print "alert( 'Bang! Bang!' );";
  $logger->debug($line);

  # print "alert( \"Hello\" );\n";
  # print "alert( menu_names[0] );\n";

}

=head2 week_fixtures

Returns the javascript for 2 functions: validate_menu_form and calculate_points.

=cut

# *********************************************
sub week_fixtures {

  # *********************************************
  my %args = (@_);

  my $q = $args{-query};
  my $line;
  my $u = $args{-util};
  $line = qq/
  
     function validate_menu_form() {
       var i = 0;
       var f = document.menu_form;
       while ( f["homeplayed" + i] ) {
         if ( f["homeplayed"+i].value == "N" || f["awayplayed"+i].value == "N" ) {
           if ( f["hometotalpts"+i].value >0 || f["awaytotalpts"+i].value > 0 ) {
             alert( "This match was not played! Points should be 0. Match: " + i );
             return false;
           }  
         }
         else {  
           if ( f["homeresult"+i].value == f["awayresult"+i].value ) {
             if ( f["homeresult"+i].value.search( \/[WL]\/ ) >= 0 ) {
               alert( "If one team won, surely the other lost! Match: " + i );
               return false;
             }  
           }
           if ( f["home"+i].value == "" || f["away"+i].value == "" ) {
             if ( f["homeplayed"+i].value == "Y" || f["awayplayed"+i].value == "Y" ) {
               alert( "No fixture. Please set played to N. Match: " + i );
               return false;
             }
           }
         }  
         i++;
       }
       return true;
     }
     
     function calculate_points( obj, i ) {

       var ok = true;
       var check_int = function(i,m) { if (! Number.isInteger(parseInt(i))) { alert(m + " must be an integer. " + i ); ok=false; } };

       var name = obj.name;
       var venue;
       if ( name.search( \/^home\/ ) >= 0 ) {
         venue = "home";
       }
       else {
         venue = "away";
       }
       if ( document.menu_form[venue+"played"+i].value == "N" 
           && ( obj.value.search( \/^[0-9]\/ ) >= 0 ) 
           && obj.value > 0 ) {
         obj.value = "";
         alert( "This match has not been played!" );
         return;
       }
              
       var resultpts = document.menu_form[venue+"resultpts"+i].value;
       var battingpts = document.menu_form[venue+"battingpts"+i].value;
       var bowlingpts = document.menu_form[venue+"bowlingpts"+i].value;
       var penaltypts = document.menu_form[venue+"penaltypts"+i].value;

       resultpts = resultpts ? resultpts : 0
       battingpts = battingpts ? battingpts : 0;
       bowlingpts = bowlingpts ? bowlingpts : 0;
       penaltypts = penaltypts ? penaltypts : 0;

       check_int(battingpts,"batting points");
       check_int(bowlingpts,"bowling points");
       check_int(penaltypts,"penalty points");
       check_int(resultpts,"result points");

       if (ok==true){
         var totalpts = parseInt( resultpts ) + parseInt( battingpts ) + parseInt( bowlingpts ) - parseInt( penaltypts );
         document.menu_form[venue+"totalpts"+i].value = totalpts;
       }

     }
  /;
  print $line;
  $logger->debug($line);

}

=head2 get_all_dates_by_division

Return a hash ref contatining all the dates for each division keyed by cvs file name.

  $VAR1 = {
            'U9S.csv' => [
                         '7-May',
                         '14-May',
                         '21-May',
                       ]
          };

=cut

sub get_all_dates_by_division {
  my %args = (@_);
  my $c    = $args{-config};
  my $q    = $args{-query};
  my $u    = $args{-util};

  my $dates = {};

  my @x = $c->get_menu_names;
  my $path = $c->get_path( -csv_files => 'Y' ) . '/' . $c->get_season;
  $logger->debug($path);

  foreach my $div (@x) {
    my $f = Fixtures->new( -full_filename => $path . '/' . $div->{csv_file} );
    $logger->error( "No fixtures for " . $path . '/' . $div->{csv_file} ) if !$f;
    next if !$f;
    $dates->{ $div->{csv_file} } = $f->get_date_list;
  }
  $logger->debug( Dumper $dates);
  return $dates;
}

=head2 get_all_dates_by_division_as_json

=cut

sub get_all_dates_by_division_as_json {
  my %args = (@_);
  my $c    = $args{-config};
  my $q    = $args{-query};
  my $u    = $args{-util};

  my $dates = get_all_dates_by_division( -config => $c, -query => $q, -util => $u );

  my @lines = ();
  foreach my $div ( keys %$dates ) {
    my $line = "'" . $div . "':";

    my @weeks = map { "'" . $_ . "'" } @{ $dates->{$div} };
    my $week_line = join( ",\n", @weeks );
    $line .= '[' . $week_line . ']';

    push @lines, $line;
  }
  my $out = '{' . join( ",\n", @lines ) . '}';
  $logger->debug( Dumper $out);
  return $out;
}

=head2 main

=cut

# *********************************************
sub main {

  # *********************************************

  my $err = 0;
  my ( $log_path, $log_dir, $log_file, $LOG );

  my $q      = CGI->new();
  my $system = $q->param("system") || "";
  my $page   = $q->param("page") || "";
  my $f      = "../custom/$system/$system.ini" if $system;

  my $c = ResultsConfiguration->new( -full_filename => $f );

  $c->read_file();

  my $u = Fcutils2->new( -append_to_logfile => 'Y', -auto_clean => 'Y' );
  $logger = $u->get_logger->logger;
  $logger->debug("In menu_js.pl page=$page system=$system");

  $log_path = $c->get_path( -log_dir => "Y" ) if !$err;

  $log_file = $c->get_log_stem($system) if !$err;

  $err = $u->get_logger->set_log_dir($log_path) if !$err;

  $u->get_locker()->set_lock_dir($log_path) if !$err;

  $err = $u->get_locker()->open_lock_file( $log_file . "js" ) if !$err;

  ( $err, $LOG ) = $u->get_logger->open_log_file( $log_file . "js" ) if !$err;

  return $err if $err;

  print $q->header( -type => "text/javascript", -expires => "+1m" );

  if ( $q->param("page") ne "week_fixtures" ) {
    menu( -config => $c, -query => $q, -util => $u );

    print "all_dates = \n"
      . get_all_dates_by_division_as_json( -config => $c, -query => $q, -util => $u ) . ";\n";
  }
  else {
    week_fixtures( -config => $c, -query => $q, -util => $u );
  }

  $u->get_logger->close_log_file( $LOG, $err );
  $u->get_locker()->close_lock_file;

}

main;
