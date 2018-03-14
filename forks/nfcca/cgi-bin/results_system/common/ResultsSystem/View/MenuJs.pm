package ResultsSystem::View::MenuJs;

=head1 NAME

ResultsSystem::View::MenuJs

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

use strict;
use warnings;
use CGI;
use Data::Dumper;

use parent qw/ResultsSystem::View/;

use JSON::Tiny qw(decode_json encode_json);

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};

  bless $self, $class;
  $self->{logger} = $args->{-logger};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;

  $self->render_javascript(
    {     -data => "var all_dates = "
        . encode_json( $args->{-data}->{all_dates} ) . ";\n\n"
        . $args->{-data}->{menu_names} . "\n"
    }
  );

}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;
