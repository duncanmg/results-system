#! /usr/bin/perl

use CGI;
use strict;
use Test::More;

unshift @INC, "../common";

# *******************************************************
sub can_use {
# *******************************************************
  my $module = shift;
  my $err = 0;
  my $msg = "ok";
  eval {
    require $module;
  };
  if ( $@ ) {
    $err = 1;
    $msg = $@;
  }
  return ( $err, $msg );
}

# *******************************************************
sub test_module_availability {
# *******************************************************
  my ( $ret, $msg );
  my $err = 0;
  my @module_list = ( # Standard Perl modules
                      "CGI.pm", "Test/More.pm", "Slurp.pm",
                      "Regexp/Common.pm", "Test/Harness.pm",
                      # Custom modules for project
                      "Fcutils2.pm", "WeekFixtures.pm", "WeekData.pm",
                      "Slurp.pm", "ResultsIndex.pm", "ResultsConfiguration.pm",
                      "Pwd.pm", "Parent.pm", "Menu.pm",
                      "LeagueTable.pm", "Fixtures.pm", "TablesIndex.pm"
                      # Test scripts
    );
  
  foreach my $m ( @module_list ) {
  
    ( $ret, $msg ) = can_use( $m );
    ok( $ret == 0, "Module $m is available. $msg.<br/>" );
    if ( $ret != 0 ) {
      $err = 1;
    }  
    
  }
  return $err;  
}

my $builder = Test::More->builder;

# Stops the number of tests being output at the beginning. "1 .. 10"
# Needs to be set before ->plan is called.
$builder->no_header( 1 );

# Stops the trailer about the number of tests.
$builder->no_ending( 1 );

# Sends the diagnostic and error messages to the standard output so that they display
# in the browser.
$builder->failure_output( \*STDOUT );

# Now call the plan.
Test::More->builder->plan( tests => 17 );

my $q = CGI->new;

print $q->header;
print $q->start_html;

test_module_availability;

print $builder->_ending;

print $q->end_html;
