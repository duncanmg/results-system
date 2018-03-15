  package ResultsSystem::Controller::Blank;

  use strict;
  use warnings;

=head1 NAME

ResultsSystem::Controller::Blank

=cut

=head1 SYNOPSIS

Return a blank HTML page.

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
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->{logger} = $args->{logger} if $args->{logger};
    $self->{blank_view} = $args->{-blank_view};
    return $self;
  }

=head2 run

=cut

  sub run {
    my ( $self, $args ) = @_;

    $self->get_blank_view->run( { -data => {} } );

    return 1;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_blank_view

=cut

  sub get_blank_view {
    my $self = shift;
    return $self->{blank_view};
  }

  1;

