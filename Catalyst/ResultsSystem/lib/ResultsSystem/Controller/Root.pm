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

  # Hello World
  # $c->response->body( $c->welcome_message );

  my $p = $c->request->parameters;
  $c->log->debug( Dumper $p);

  my $datetime_natural = DateTime::Format::Natural->new;
  my $fixtures_handler = ResultsSystem::Fixtures::Parser->new(
    source_file      => '/home/duncan/git/results-system-v3/ResultsSystem/t/2012RD4NW.csv',
    csv              => Text::CSV->new(),
    datetime_natural => $datetime_natural
  );

  my $writer =
    ResultsSystem::IO::XML->new(
    full_filename => '/home/duncan/git/results-system-v3/ResultsSystem/t/2012RD4NW.xml' );

  my $rparser = ResultsSystem::Results::Parser->new(
    fixtures_file    => '/home/duncan/git/results-system-v3/ResultsSystem/t/2012RD4NW.csv',
    fixtures_handler => $fixtures_handler,
    results_file     => '/home/duncan/git/results-system-v3/ResultsSystem/t/2012RD4NW.xml',
    results_handler  => $writer,
    week_commencing =>
      $datetime_natural->parse_datetime( $p->{week_commencing} || "28 February 2015" )
  );

  $rparser->parse_file;

  if ( $p->{submit} ) {
    $c->log->debug("Submit!");

    my $parsed = $rparser->parse_input($p);
    $c->log->debug( Dumper $parsed);
    $writer->write($parsed);
  }

  $c->log->warn( "Got " . $rparser->results->count . " weeks in season." );
  $c->log->warn( "\n" . $rparser->results );

  my $week1 = $rparser->results->iterator->();

  $c->log->debug( "week 1 is " . $week1 );

  $c->stash(
    template        => 'static/fixtures.tt',
    action          => $c->uri_for('/'),
    division        => 'One',
    week_commencing => "28 February 2015",
    fixtures        => $week1->iterator
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
