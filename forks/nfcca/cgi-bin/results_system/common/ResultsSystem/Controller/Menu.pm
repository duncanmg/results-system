  # ***************************************************************************
  #
  # Name: Menu.pm
  #
  # 0.1  - 25 Jun 08 - POD updated.
  #
  # ***************************************************************************

  package ResultsSystem::Controller::Menu;

  use strict;
  use warnings;

=head1 ResultsSystem::Controller::Menu

=cut

  sub new {
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->{logger}     = $args->{logger} if $args->{logger};
    $self->{menu_model} = $args->{-menu_model};
    $self->{menu_view}  = $args->{-menu_view};
    return $self;
  }

  sub run {
    my ( $self, $args ) = @_;

    my $data = $self->get_menu_model->run();

    $self->get_menu_view->run( { -data => $data } );

  }

  sub get_menu_model {
    my $self = shift;
    return $self->{menu_model};
  }

  sub get_menu_view {
    my $self = shift;
    return $self->{menu_view};
  }

  1;

