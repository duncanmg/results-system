package ResultsSystem::View::Message;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data} || '&nbsp;';

  my $html = $self->merge_content( $self->html_wrapper,
    { CONTENT => $data, STYLESHEETS => "", PAGETITLE => 'Results System' } );

  $self->render( { -data => $html } );
}

1;

