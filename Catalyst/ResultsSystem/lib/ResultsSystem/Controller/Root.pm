package ResultsSystem::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use ResultsSystem::Fixtures::Parser;
use ResultsSystem::Results::Parser;
use ResultsSystem::IO::XML;
use Text::CSV;
use DateTime::Format::Natural;
use Data::Dumper;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=encoding utf-8

=head1 NAME

ResultsSystem::Controller::Root - Root Controller for ResultsSystem

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index : Path : Args(0) {
  my ( $self, $c ) = @_;

  my $p = $c->request->parameters;
  $c->log->debug( Dumper $p);

my $parser = DateTime::Format::Natural->new;
my $match_date = $parser->parse_datetime('2015-05-12');
$c->log->debug("Match date: ". $match_date."");

my @matches = $c->model('DB::Match')->matches_for_date_and_division_ordered( $match_date."");
$c->log->debug(Dumper map { [ "match_id: " . $_->id , (map { $_."" } $_->match_details) ] } @matches);

my $fixtures;

  $c->stash(
    template        => 'static/fixtures.tt',
    action          => $c->uri_for('/'),
    division        => 'One',
    week_commencing => $match_date,
    fixtures        => \@matches
  );
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
  my ( $self, $c ) = @_;
  $c->response->body('Page not found');
  $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

Duncan Garland,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
