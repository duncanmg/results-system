package ResultsSystem::View::Blank;

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
  my $data = $args->{-data};

  my $html = $self->merge_content( $self->html_wrapper,
    { CONTENT => '<p>&nbsp;</p>', PAGETITLE => 'Results System', STYLESHEETS => "" } );

  $self->render( { -data => $html } );
}

1;

