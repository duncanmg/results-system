  package ResultsSystem::Controller::Menu;

=head1 NAME

ResultsSystem::Controller::Menu

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

None

=cut

  use strict;
  use warnings;

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

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

=head2 run

=cut

  sub run {
    my ( $self, $args ) = @_;

    my $data = $self->get_menu_model->run();

    $self->get_menu_view->run( { -data => $data } );

    return 1;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_menu_model

=cut

  sub get_menu_model {
    my $self = shift;
    return $self->{menu_model};
  }

=head2 get_menu_view

=cut

  sub get_menu_view {
    my $self = shift;
    return $self->{menu_view};
  }

  1;

