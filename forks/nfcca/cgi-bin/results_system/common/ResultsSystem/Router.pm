package ResultsSystem::Router;

use strict;
use warnings;
use Params::Validate qw/:all/;

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

  my $pages = {
    'frame'         => sub { $self->get_factory->get_frame_controller->run($query) },
    'menu'          => sub { $self->get_factory->get_menu_controller->run($query) },
    'blank'         => sub { $self->get_factory->get_blank_controller->run($query) },
    'menu_js'       => sub { $self->get_factory->get_menu_js_controller->run($query) },
    'week_fixtures' => sub { $self->get_factory->get_week_fixtures_controller->run($query) }
    'save_results' => sub { $self->get_factory->get_save_results_controller->run($query) }
  };

  my $page = $query->param('page');
  if ( $pages->{$page} ) {
    $pages->{$page}->();
  }

}

sub get_factory {
  my $self = shift;
  return $self->{factory};
}

sub set_factory {
  my ( $self, $f ) = @_;
  $self->{factory} = $f;
  return $self;
}

1;
