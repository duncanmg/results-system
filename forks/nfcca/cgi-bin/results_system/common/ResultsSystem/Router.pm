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

sub route {
  my ( $self, $query ) = @_;

  my $pages = {
    'frame' => sub { $self->get_factory->get_frame_controller->run($query) }
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
