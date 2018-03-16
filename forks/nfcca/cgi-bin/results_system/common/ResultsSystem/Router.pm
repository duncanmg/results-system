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

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  bless $self, $class;
  $self->set_factory( $args->{-factory} ) if $args->{-factory};
  return $self;
}

=head2 route

=cut

=head3 Routes

=over 

=item frame

=item menu

=item blank

=item menu_js

=item week_fixtures

=back

=cut

sub route {
  my ( $self, $query ) = @_;

  eval {
    my $pages = {
      'frame'         => sub { $self->get_factory->get_frame_controller->run($query) },
      'menu'          => sub { $self->get_factory->get_menu_controller->run($query) },
      'blank'         => sub { $self->get_factory->get_blank_controller->run($query) },
      'menu_js'       => sub { $self->get_factory->get_menu_js_controller->run($query) },
      'week_fixtures' => sub { $self->get_factory->get_week_fixtures_controller->run($query) },
      'save_results'  => sub { $self->get_factory->get_save_results_controller->run($query) },
      'results_index' => sub { $self->get_factory->get_results_index_controller->run($query) },
      'tables_index'  => sub { $self->get_factory->get_tables_index_controller->run($query) }
    };

    my $page = $query->param('page');
    if ( $pages->{$page} ) {
      $pages->{$page}->();
    }
    1;
  } || do {
    my $e = $@;
    $self->get_factory->get_file_logger( { -category => ref($self) } )->error($e);
    croak 'Error. See log';
  };
  return 1;
}

=head2 get_factory

=cut

sub get_factory {
  my $self = shift;
  return $self->{factory};
}

=head2 set_factory

=cut

sub set_factory {
  my ( $self, $f ) = @_;
  $self->{factory} = $f;
  return $self;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;
