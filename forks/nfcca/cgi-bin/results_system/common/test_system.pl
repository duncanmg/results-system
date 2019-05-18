#! /usr/bin/perl

use CGI;
use strict;
use warnings;

use Test::More;

BEGIN {
  use LoadEnv;
  LoadEnv::run();
}

# *******************************************************
sub test_module_availability {

  # *******************************************************
  my $err         = 0;
  my @module_list = qw!
    ResultsSystem::AutoCleaner ResultsSystem::Configuration ResultsSystem::Controller::Blank ResultsSystem::Controller::Frame
    ResultsSystem::Controller::LeagueTable ResultsSystem::Controller::Menu ResultsSystem::Controller::MenuJs ResultsSystem::Controller::Pwd
    ResultsSystem::Controller::ResultsIndex ResultsSystem::Controller::SaveResults ResultsSystem::Controller::TablesIndex ResultsSystem::Controller::WeekFixtures
    ResultsSystem::Controller::WeekResults ResultsSystem::Exception ResultsSystem::Locker ResultsSystem::Logger
    ResultsSystem::Model ResultsSystem::Model::FixtureList ResultsSystem::Model::Frame ResultsSystem::Model::LeagueTable
    ResultsSystem::Model::Menu ResultsSystem::Model::MenuJs ResultsSystem::Model::Pwd ResultsSystem::Model::ResultsIndex
    ResultsSystem::Model::SaveResults ResultsSystem::Model::Store ResultsSystem::Model::Store::Divisions ResultsSystem::Model::TablesIndex
    ResultsSystem::Model::WeekFixtures::Adapter ResultsSystem::Model::WeekFixtures::Selector ResultsSystem::Model::WeekResults::Reader ResultsSystem::Model::WeekResults::Writer
    ResultsSystem::Router ResultsSystem::Starter ResultsSystem::View ResultsSystem::View::Blank
    ResultsSystem::View::Frame ResultsSystem::View::LeagueTable ResultsSystem::View::Menu ResultsSystem::View::MenuJs
    ResultsSystem::View::Message ResultsSystem::View::Pwd ResultsSystem::View::ResultsIndex ResultsSystem::View::TablesIndex
    ResultsSystem::View::Week ResultsSystem::View::Week::FixturesForm ResultsSystem::View::Week::Results
    !;

  foreach my $m (@module_list) {
    print "<p>\n";
    my $ok = require_ok($m);
    print "</p>\n";
    print "<p style='color:red'>The last test failed.</p>" if !$ok;
  }
  return $err;
}

my $builder = Test::More->builder;

# Stops the number of tests being output at the beginning. "1 .. 10"
# Needs to be set before ->plan is called.
$builder->no_header(1);

# Stops the trailer about the number of tests.
$builder->no_ending(1);

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

