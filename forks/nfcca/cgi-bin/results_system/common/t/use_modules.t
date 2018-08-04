use strict;
use warnings;
use Test::More;

use_ok('Carp::Assert');
use_ok('CGI');
use_ok('Clone');
use_ok('Regexp::Common');
use_ok('File::Copy');
use_ok('Data::Dumper');
use_ok('parent');
use_ok('List::MoreUtils');
use_ok('Slurp');
use_ok('Params::Validate');

use_ok('ResultsSystem::AutoCleaner');
use_ok('ResultsSystem::Configuration');
use_ok('ResultsSystem::Factory');
use_ok('ResultsSystem::Locker');
use_ok('ResultsSystem::Logger');
use_ok('ResultsSystem::Router');
use_ok('ResultsSystem::Starter');

use_ok('ResultsSystem::Controller::Blank');
use_ok('ResultsSystem::Controller::Frame');
use_ok('ResultsSystem::Controller::Menu');
use_ok('ResultsSystem::Controller::MenuJs');
use_ok('ResultsSystem::Controller::SaveResults');
use_ok('ResultsSystem::Controller::TablesIndex');
use_ok('ResultsSystem::Controller::WeekFixtures');

use_ok('ResultsSystem::Model::FixtureList');
use_ok('ResultsSystem::Model::Frame');
use_ok('ResultsSystem::Model::LeagueTable');
use_ok('ResultsSystem::Model::Menu');
use_ok('ResultsSystem::Model::MenuJs');
use_ok('ResultsSystem::Model::Pwd');
use_ok('ResultsSystem::Model::ResultsIndex');
use_ok('ResultsSystem::Model::SaveResults');
use_ok('ResultsSystem::Model::TablesIndex');
use_ok('ResultsSystem::Model::WeekResults::Reader');
use_ok('ResultsSystem::Model::WeekResults::Writer');
use_ok('ResultsSystem::Model::WeekFixtures');
use_ok('ResultsSystem::Model::Store::Divisions');

use_ok('ResultsSystem::View::Blank');
use_ok('ResultsSystem::View::Frame');
use_ok('ResultsSystem::View::LeagueTable');
use_ok('ResultsSystem::View::Menu');
use_ok('ResultsSystem::View::MenuJs');
use_ok('ResultsSystem::View::Message');
use_ok('ResultsSystem::View::Pwd');
use_ok('ResultsSystem::View::ResultsIndex');
use_ok('ResultsSystem::View::TablesIndex');
use_ok('ResultsSystem::View::Week::FixturesForm');
use_ok('ResultsSystem::View::Week::Results');

done_testing;

