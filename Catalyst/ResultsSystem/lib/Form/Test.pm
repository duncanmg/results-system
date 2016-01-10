package Form::Test;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'foo';
has_field 'bar' => ( type => 'Select' );

has_field 'match' => (type => 'Repeatable' );

has_field 'match.home_id';
has_field 'match.away_id';

no HTML::FormHandler::Moose;

1;
