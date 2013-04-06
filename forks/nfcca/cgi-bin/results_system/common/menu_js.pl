#!/usr/bin/perl

use strict;
use warnings;
use CGI;

use ResultsConfiguration;
use Fcutils2;


# *********************************************
sub menu(%) {
# *********************************************
  my %args = ( @_ );
  my $c = $args{-config};
  my $q = $args{-query};
  my $u = $args{-util};
  my $line;
  
  my @x = $c->get_menu_names;

  $line =  "if ( typeof( menu_names ) == \"undefined\" ) { menu_names = new Array(); }\n";
  # print "if ( typeof( menu_names ) == null ) { menu_names = new Array(); }\n";

  $line = $line .  "if ( typeof( csv_files ) == \"undefined\" ) { csv_files = new Array(); }\n\n";

  foreach my $x ( @x ) {

    $line = $line . "menu_names.push( \"" . $x->{menu_name} . "\" );\n";
    $line = $line . "csv_files.push( \"" . $x->{csv_file} . "\" );\n\n";

  }

  # print "alert('Bang!');";
  print $line;
  # print "alert( 'Bang! Bang!' );";
  $u->eAdd( $line, 2 );
  # print "alert( \"Hello\" );\n";
  # print "alert( menu_names[0] );\n";

}

# *********************************************
sub week_fixtures(%) {
# *********************************************
  my %args = ( @_ );
  my $c = $args{-config};
  my $q = $args{-query};
  my $line;
  my $u = $args{-util};
  
  my $win  = $c->get_points( "win" );
  my $loss = $c->get_points( "loss" );
  my $tie  = $c->get_points( "tie" );
  my $points = "";
  my $err = 0;
  
  $points  = "win=$win;"   if $win =~ m/\d/;
  $points .= "loss=$loss;" if $loss =~ m/\d/;
  $points .= "tie=$tie;"   if $tie =~ m/\d/;
  $points .= "\n";
  
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
     
     function get_venue( name ) {
       var venue = "";
       if ( name.search( \/^home\/ ) >= 0 ) {
         venue = "home";
       }
       else {
         venue = "away";
       }
       return venue;     
     }
     
     function calculate_points( obj, i ) {
       var name = obj.name;
       var venue;
       var win = -1;
       var loss = -1;
       var tie  = -1;
       $points
       venue = get_venue( name );
       if ( document.menu_form[venue+"played"+i].value == "N" 
           && ( obj.value.search( \/^[0-9]\/ ) >= 0 ) 
           && obj.value > 0 ) {
         obj.value = "";
         alert( "This match has not been played!" );
         return;
       }
       
       var resultpts = document.menu_form[venue+"resultpts"+i].value;
       var s = document.menu_form[venue+"result"+i];
       var r = s.options[s.selectedIndex].value;

       if ( r == "W" && win >= 0 ) {
         resultpts = win;
       }

       if ( r == "L" && loss >= 0 ) {
         resultpts = loss;
       }
       
       if ( r == "T" && tie > 0 ) {
         resultpts = tie;
       }
       
       var battingpts = document.menu_form[venue+"battingpts"+i].value;
       var bowlingpts = document.menu_form[venue+"bowlingpts"+i].value;
       var penaltypts = document.menu_form[venue+"penaltypts"+i].value;
       resultpts = resultpts ? resultpts : 0
       battingpts = battingpts ? battingpts : 0;
       bowlingpts = bowlingpts ? bowlingpts : 0;
       penaltypts = penaltypts ? penaltypts : 0;
       var totalpts = parseInt( resultpts ) + parseInt( battingpts ) + parseInt( bowlingpts ) - parseInt( penaltypts );
       document.menu_form[venue+"totalpts"+i].value = totalpts;
       document.menu_form[venue+"resultpts"+i].value = resultpts;

     }
     
     function initialise_line( obj, i ) {
       var name = obj.name;
       var venue = get_venue( name );
       if ( obj.value == 'N' ) {
         document.menu_form[venue+"battingpts"+i].value = "";
         document.menu_form[venue+"bowlingpts"+i].value = "";
         document.menu_form[venue+"penaltypts"+i].value = "";
         document.menu_form[venue+"resultpts"+i].value = "";
         document.menu_form[venue+"totalpts"+i].value = "";         
         document.menu_form[venue+"performances"+i].value = "";         
       }
       else {
         calculate_points( obj, i );
       }
     }

  /; # End of javascript!   

  print $line;
  $u->eAdd( $line, 2 );
  return $err; 
}

# *********************************************
sub main(;) {
# *********************************************

  my $err = 0;
  my ( $log_path, $log_dir, $log_file, $LOG );
  
  my $q = CGI->new();
  map { $q->param( -name => $_, -value => "" ) if ! $q->param( $_ ) } ( "system", "page", "user" );
  my $system = $q->param( "system" ) || "";
  my $page = $q->param( "page" ) || "";
  my $f = "../custom/$system/$system.ini" if $system;

  my $u = Fcutils2->new( -append_to_logfile => 'Y', -auto_clean => 'Y' );
  $u->eAdd( "In menu_js.pl page=$page system=$system", 2 );

  my $c = ResultsConfiguration->new( -full_filename => $f );
  if ( ! $c ) {
    $u->eAdd( $ResultsConfiguration::create_errmsg, 5 );
    $err = 1;
  }    
  
  $c->read_file() if ! $err;

  if ( $err == 0 ) {
    $log_path = $c->get_path( -log_dir => "Y" );
    $log_file = $c->get_log_stem( $system );
  }

  if ( $err == 0 ) {
    $err = $u->SetLogDir( $log_path );
  }
  if ( $err == 0 ) {
    $u->set_lock_dir( $log_path );
  }
  
  if ( $err == 0 ) {
    $err = $u->OpenLockFile( $log_file . "js" );
  }
  if ( $err == 0 ) {
    ( $err, $LOG ) = $u->OpenLogFile( $log_file . "js" );
  }
  if ( $err != 0 ) {
    print STDERR $u->eDump;
    print "<p>". $u->eDump . "</p>\n";
    return $err;
  }  

  print $q->header( -type => "text/javascript", -expires => "+1m" );

  if ( $q->param( "page" ) ne "week_fixtures" ) {
    menu( -config => $c, -query => $q, -util => $u );
  }
  else {
    week_fixtures( -config => $c, -query => $q, -util => $u );
  }

  print "\nmenu_js = 1;\n";
  $u->eSetMinDebug( 0 );
  print $LOG $u->eDump();  
  $u->CloseLogFile( $LOG, $err );
  $u->CloseLockFile;
  
}

main;