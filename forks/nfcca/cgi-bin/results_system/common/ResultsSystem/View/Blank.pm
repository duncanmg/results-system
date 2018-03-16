
=head1 NAME

ResultsSystem::View::Blank

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::View

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::View::Blank;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $html = $self->merge_content( $self->html_wrapper,
    { CONTENT => '<p>&nbsp;</p>', PAGETITLE => 'Results System', STYLESHEETS => "" } );

  $self->render( { -data => $html } );
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

1;

