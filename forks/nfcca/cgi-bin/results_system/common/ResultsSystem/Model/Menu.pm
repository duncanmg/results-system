package ResultsSystem::Model::Menu;

use strict;
use warnings;
use parent qw/ ResultsSystem::Model/;

=head1 NAME

ResultsSystem::Model::Menu

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  return $self;
}

=head2 run

=cut

# ******************************************************
sub run {

  # ******************************************************
  my $self = shift;
  my %args = (@_);
  my $c    = $self->get_configuration();

  my ( $link, $title ) = $self->get_configuration->get_return_page;

  my $data = {
    RETURN_TO_LINK  => $link,
    RETURN_TO_TITLE => $title,
    HTDOCS          => $c->get_path( -htdocs => "Y", -allow_not_exists => "Y" ) . "/common",
    SYSTEM          => $c->get_system
  };

}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;

