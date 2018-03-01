package ResultsSystem::Controller::TablesIndex;

=head1 ResultsSystem::Controller::TablesIndex

=cut

use strict;
use warnings;

=head1 Methods

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->{logger}             = $args->{-logger}             if $args->{-logger};
  $self->{tables_index_model} = $args->{-tables_index_model} if $args->{-tables_index_model};
  $self->{tables_index_view}  = $args->{-tables_index_view}  if $args->{-tables_index_view};

  return $self;
}

=head3 run

=cut

sub run {
  my ( $self, $query ) = @_;

  my $data = $self->get_tables_index_model()->run();

  $self->get_tables_index_view()->run( { -data => $data } );
}

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head2 get_tables_index_model

=cut

sub get_tables_index_model {
  my $self = shift;
  return $self->{tables_index_model};
}

=head2 get_tables_index_view

=cut

sub get_tables_index_view {
  my $self = shift;
  return $self->{tables_index_view};
}

1;

