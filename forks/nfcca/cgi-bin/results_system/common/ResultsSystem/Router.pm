package ResultsSystem::Router;

use strict;
use warnings;
use Params::Validate qw/:all/;
use Carp;

=head1 NAME

ResultsSystem::Router

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Each routes calls one or more controller and passes it the query object. The controllers 
aren't called directly, by via the appropriate factory method.

=head2 List Of Routes

=head3 Simple Routes

These call a single controller.

=over 

=item blank - Controller::Blank

=item frame - Controller::Frame

=item menu - Controller::Menu

=item menu_js - Controller::MenuJs

=item results_index - Controller::ResultsIndex

=item tables_index - Controller::TablesIndex

=item week_fixtures - Conroller::WeekFixtures

=back

=head3 Complex Routes

These call several controllers in order. If one throws an exception or returns false then the subsequent ones aren't processed.

=over

=item save_results - Controller::Pwd, Controller::SaveResults, Controller::LeagueTable, Controller:WeekResults 

=back

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

Constructor which accepts the factory as an argument.

$r = ResultsSystem::Factory->new({ -factory => $factory });

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  bless $self, $class;
  $self->set_factory( $args->{-factory} ) if $args->{-factory};
  return $self;
}

=head2 route

$self->route($query);

Accepts a CGI object as an argument and calls the run() method on the relevant controller.

=cut

sub route {
  my ( $self, $query ) = @_;

  eval {
    my $pages = $self->_get_pages($query);

    my $not_found = sub {
      $self->_get_factory->get_message_view->run(
        { -data        => 'Page Not Found',
          -status_code => 404
        }
      );
    };

    my $page = $query->param('page');

    if ( $pages->{$page} ) {
      $pages->{$page}->();
    }
    else {
      $not_found->();
    }
    1;
  } || do {
    my $e = $@;
    $self->_get_factory->get_file_logger( { -category => ref($self) } )->error($e);
    croak 'Error. See log';
  };
  return 1;
}

=head2 set_factory

Sets the factory object.

=cut

sub set_factory {
  my ( $self, $f ) = @_;
  $self->{factory} = $f;
  return $self;
}

=head2 set_pages

Only used for testing.

=cut

sub set_pages {
  my ( $self, $hr ) = validate_pos( @_, 1, { type => HASHREF } );
  $self->{pages} = $hr;
  return $self;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_factory

Returns the factory object.

=cut

sub _get_factory {
  my $self = shift;
  return $self->{factory};
}

=head2 _get_pages

=cut

sub _get_pages {
  my ( $self, $query ) = validate_pos( @_, 1, 1 );
  $self->{pages} = {
    'frame'         => sub { $self->_get_factory->get_frame_controller->run($query) },
    'menu'          => sub { $self->_get_factory->get_menu_controller->run($query) },
    'blank'         => sub { $self->_get_factory->get_blank_controller->run($query) },
    'menu_js'       => sub { $self->_get_factory->get_menu_js_controller->run($query) },
    'week_fixtures' => sub { $self->_get_factory->get_week_fixtures_controller->run($query) },
    'save_results'  => sub {
           $self->_get_factory->get_pwd_controller->run($query)
        && $self->_get_factory->get_save_results_controller->run($query)
        && $self->_get_factory->get_league_table_controller->run($query)
        && $self->_get_factory->get_week_results_controller->run($query);
    },
    'results_index' => sub { $self->_get_factory->get_results_index_controller->run($query) },
    'tables_index'  => sub { $self->_get_factory->get_tables_index_controller->run($query) }
  } if !$self->{pages};
  return $self->{pages};

}

1;
