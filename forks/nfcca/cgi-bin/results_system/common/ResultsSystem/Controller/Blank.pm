  # ***************************************************************************
  #
  # Name: Blank.pm
  #
  # 0.1  - 25 Jun 08 - POD updated.
  #
  # ***************************************************************************

  package ResultsSystem::Controller::Blank;

  use strict;
  use warnings;

=head1 ResultsSystem::Controller::Blank

=cut

  sub new {
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->{logger}     = $args->{logger} if $args->{logger};
    $self->{blank_view}  = $args->{-blank_view};
    return $self;
  }

  sub run {
    my ( $self, $args ) = @_;

    $self->get_blank_view->run( { -data => {} } );

  }

  sub get_blank_view {
    my $self = shift;
    return $self->{blank_view};
  }

  1;

