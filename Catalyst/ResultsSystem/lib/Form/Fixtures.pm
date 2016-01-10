package Form::Fixtures;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'fixture' => ( type => 'Repeatable' );

has_field 'fixture.home' => ( type => 'Compound' );

has_field 'fixture.away' => ( type => 'Compound' );

has_field 'fixture.home.id';
has_field 'fixture.home.name';
has_field 'fixture.home.played';
has_field 'fixture.home.result';
has_field 'fixture.home.runs_scored';
has_field 'fixture.home.wickets_lost';
has_field 'fixture.home.comments';

has_field 'fixture.away.id';
has_field 'fixture.away.name';
has_field 'fixture.away.played';
has_field 'fixture.away.result';
has_field 'fixture.away.runs_scored';
has_field 'fixture.away.wickets_lost';
has_field 'fixture.away.comments';

no HTML::FormHandler::Moose;

1;
