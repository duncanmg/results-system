package ResultsSystem::View;

use strict;
use warnings;

=head1 NAME

ResultsSystem::View

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Base class for views.

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

use CGI;
use HTTP::Response;
use HTTP::Status qw/:constants status_message/;
use Params::Validate qw/:all/;

use JSON::Tiny qw(decode_json encode_json);
use HTML::HTML5::Entities qw();

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head2 set_logger

=cut

sub set_logger {
  my $self = shift;
  $self->{logger} = shift;
  return $self;
}

=head2 set_configuration

=cut

sub set_configuration {
  my ( $self, $v ) = @_;
  $self->{configuration} = $v;
  return $self;
}

=head2 get_configuration

=cut

sub get_configuration {
  my $self = shift;
  return $self->{configuration};
}

=head2 set_arguments

Helper method to set the constructor arguments of the child classes.

$self->set_arguments( [ qw/ logger configuration week_data fixtures / ], $args );

=cut

sub set_arguments {
  my ( $self, $map, $args ) = validate_pos( @_, 1, { type => ARRAYREF }, { type => HASHREF } );

  foreach my $m (@$map) {
    my $method = 'set_' . $m;
    my $key    = '-' . $m;
    $self->$method( $args->{$key} );
  }
  return 1;
}

=head2 encode_entities

=cut

sub encode_entities {
  my ( $self, $unencoded ) = validate_pos( @_, 1, 1 );
  return HTML::HTML5::Entities::encode_entities($unencoded);
}

=head2 set_renderer

May be useful during testing. It allows the rendered output to
be diverted or captured.

  $self->set_renderer( $code_ref );

The code_ref must accept an array ref of strings and do something with them.

The default action is to print them to the standard output.

=cut

sub set_renderer {
  my ( $self, $code_ref ) = validate_pos( @_, 1, { type => CODEREF } );
  $self->{renderer} = $code_ref;
  return $self;
}

=head1 TEMPLATING METHODS (PUBLIC)

=cut

=head2 render

Prints an HTTP response to the standard output. Status defaults to 200.
Character set defaults to UTF-8. Content type text/html.

The response content is the HTML provided as the -data key.

  $self->render( { -data => $html } );

  $self->render( { -data => $html, -charset => 'ISO-8859-1',
    -status_code => HTTP_OK } );

=cut

sub render {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  $args->{-charset}     ||= 'UTF-8';
  $args->{-status_code} ||= HTTP_OK;

  my $response = HTTP::Response->new( HTTP_OK,
    status_message( $args->{-status_code} ),
    [ 'Content-Type' => "text/html; charset=$args->{-charset}",
      'Status'       => $args->{-status_code} . " " . status_message( $args->{-status_code} )
    ],
    $data
  );

  $self->_get_renderer->( [ $response->headers->as_string . "\n\n", $response->content . "\n" ] );

  return 1;
}

=head2 render_javascript

Prints an HTTP response to the standard output. Status 200.
Character set ISO-8859-1. Content type text/javascript.

The response content is the javascript provided as the -data key.

  $self->render( { -data => $js } );

=cut

sub render_javascript {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  $args->{-charset}     ||= 'UTF-8';
  $args->{-status_code} ||= HTTP_OK;

  my $response = HTTP::Response->new(
    $args->{-status_code},
    status_message( $args->{-status_code} ),
    [ 'Content-Type' => 'text/javascript; charset=' . $args->{-charset},
      'Status'       => $args->{-status_code} . " " . status_message( $args->{-status_code} )
    ],
    $data
  );

  print $response->headers->as_string . "\n\n";
  print $response->content . "\n";
  return 1;

}

=head2 render_json

Prints an HTTP response to the standard output. Status 200.
Character set ISO-8859-1. Content type text/javascript.

The response content is the hash ref provided as the -data key
converted to json.

  $self->render( { -data => $data } );

=cut

sub render_json {
  my ( $self, $hash_ref ) = @_;

  # print $q->header( -type => "text/javascript", -expires => "+1m" );

  encode_json( { 'all_dates' => $hash_ref } );

  my $response = HTTP::Response->new( HTTP_OK,
    status_message(HTTP_OK),
    [ 'Content-Type' => 'text/javascript; charset=ISO-8859-1',
      'Status'       => HTTP_OK . " " . status_message(HTTP_OK)
    ],
    encode_json($hash_ref)
  );

  print $response->headers->as_string . "\n\n";
  print $response->content . "\n";
  return 1;

}

=head2 merge_content

Accepts a block of text containing placeholders and a hashref
containg the replacements. Does a global replacement of the
placeholders.

  $html = $self->merge_content( "<p>[% name %] had a little lamb.</p.",
    { name => "Mary" } );

will return "<p>Mary had a little lamb.</p>".

=cut

sub merge_content {
  my ( $self, $html, $data ) = validate_pos( @_, 1, { type => SCALAR }, { type => HASHREF } );

  foreach my $k ( keys %$data ) {

    # $html =~ s/[% $k %]/$data->{$k}/xmsg;
    $html =~ s/\[%\s$k\s%\]/$data->{$k}/xmsg;
  }

  return $html;
}

=head2 merge_array

  $html = $self->merge_array( $row_html, $data_list );

where $data_list is an array ref of hash refs.

=cut

sub merge_array {
  my ( $self, $row_html, $data_list ) = @_;

  my $html = "";
  foreach my $row (@$data_list) {

    $html .= $self->merge_content( $row_html, $row );
  }

  return $html;
}

=head2 html_frame_wrapper

Returns the static html for the frame. Two placeholders PAGETITLE and CONTENT.

=cut

sub html_frame_wrapper {
  my $self = shift;

  my $output = <<'HTML';
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
           "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">


<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US">
<head>
<!--***************************************************************
*
*       Copyright Duncan Garland Consulting Ltd 2003-2008. All rights reserved.
*       Copyright Duncan Garland 2008-2018. All rights reserved.
*
****************************************************************-->

<title>[% PAGETITLE %]</title>

<script language="JavaScript" type="text/javascript" src="/results_system/common/common.js"></script>

</head>
  [% CONTENT %]
</html>
HTML
  return $output;
}

=head2 html_wrapper

Returns the doctype, header and body tags for an XHTML 1.0 page as a wrapper.
Three tags PAGETITLE, STYLESHEETS and CONTENT.

=cut

sub html_wrapper {
  my $self = shift;

  my $output = <<'HTML';
<!DOCTYPE html
  	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
		 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<!--***************************************************************
*
*       Copyright Duncan Garland Consulting Ltd 2003-2008. All rights reserved.
*       Copyright Duncan Garland 2008-2018. All rights reserved.
*
****************************************************************-->

<title>[% PAGETITLE %]</title>
</style>
[% STYLESHEETS %]

<script language="JavaScript" type="text/javascript" src="/results_system/common/common.js"></script>

</head>
  <body>
  [% CONTENT %]
  </body>
</html>
HTML

  return $output;
}

=head2 html5_wrapper

Returns the doctype, header and body tags for an HTML 5 page as a wrapper.
Three tags PAGETITLE, STYLESHEETS and CONTENT.

=cut

sub html5_wrapper {
  my $self = shift;

  my $output = <<'HTML';
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset="UTF-8">
<!--***************************************************************
*
*       Copyright Duncan Garland Consulting Ltd 2003-2008. All rights reserved.
*       Copyright Duncan Garland 2008-2018. All rights reserved.
*
****************************************************************-->

<title>[% PAGETITLE %]</title>
[% STYLESHEETS %]

<script src="/results_system/common/common.js"></script>

</head>
  <body>
  [% CONTENT %]
  </body>
</html>
HTML

  return $output;
}

=head2 merge_stylesheets

  $self->merge_stylesheets($html, [ "/results_system/custom/nfcca/nfcca_styles.css", 
    "/results_system/custom/nfcca/styles2.css" ]);

=cut

sub merge_stylesheets {
  my ( $self, $html, $sheets ) = validate_pos( @_, 1, { type => SCALAR }, { type => ARRAYREF } );
  my $sheets_html = '';
  foreach my $s (@$sheets) {
    $sheets_html .= '<link rel="stylesheet" type="text/css" href="' . $s . '" />' . "\n";
  }
  return $self->merge_content( $html, { STYLESHEETS => $sheets_html } );
}

=head2 merge_default_stylesheet

$html = $self->merge_default_stylesheet( $html );

=cut

sub merge_default_stylesheet {
  my ( $self, $html ) = validate_pos( @_, 1, 1 );
  my @styles = $self->get_configuration->get_stylesheets;

  my $sheet =
      $self->get_configuration->get_path( -htdocs => "Y", -allow_not_exists => "Y" )
    . "/custom/"
    . $styles[0];

  return $self->merge_stylesheets( $html, [$sheet] );
}

=head2 merge_if_in_list

Specify a list of possible replacements.

For instance this:

  $self->merge_if_in_list( $html, 'msg_colour', 'stop', [ 'stop', 'wait', 'go' ],
    [ 'red', 'amber', 'green' ] );

could be used to set the colour of a message based on the value of an input.

No default value.

=cut

sub merge_if_in_list {
  my ( $self, $html, $label, $value, $targets, $replacements ) =
    validate_pos( @_, 1, 1, 1, 1, { type => ARRAYREF }, { type => ARRAYREF } );

  my $out = "";
  my $i   = 0;
  foreach my $t (@$targets) {
    if ( ( $value || "" ) eq ( $t || "" ) ) {
      $out = $self->merge_content( $html, { $label => $replacements->[$i] } );
      last;
    }
    $i++;
  }
  return $out;
}

=head2 merge_if

Useful when working with select lists.

The HTML could be:

  <select><option value="Y" [% played_y %]>Y</option></select>

The following could will replace the label with 'selected="selected"' if $r->{played} is 'Y'.

 $row = $self->merge_if( $row, 'played_y', $r->{played}, 'Y', 'selected="selected"' );

There is no "else" or "default".

=cut

sub merge_if {
  my ( $self, $html, $label, $value, $target, $replacement ) =
    validate_pos( @_, 1, 1, 1, 1, { type => SCALAR }, { type => SCALAR } );

  my $out = $html;
  if ( ( $value || "" ) eq ( $target || "" ) ) {
    $out = $self->merge_content( $html, { $label => $replacement } );
  }
  return $out;
}

=head2 merge_if_else

Same functionality as merge_if but accepts a default value which is used if the match fails.

 $row = $self->merge_if( $row, 'played_y', $r->{played}, 'Y', 'selected="selected"', "" );

=cut

sub merge_if_else {
  my ( $self, $html, $label, $value, $target, $replacement, $default ) =
    validate_pos( @_, 1, 1, 1, 1, { type => SCALAR }, { type => SCALAR }, { type => SCALAR } );

  my $out = $html;

  if ( ( $value || "" ) eq ( $target || "" ) ) {
    $out = $self->merge_content( $html, { $label => $replacement } );
  }
  else {
    $out = $self->merge_content( $html, { $label => $default } );
  }

  return $out;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_renderer

Return the renderer code_ref which accepts an array ref of strings.

The default code_ref prints the strings to the standard output.

=cut

sub _get_renderer {
  my ($self) = validate_pos( @_, 1 );

  $self->{renderer} ||= sub {
    my $lines = shift;
    foreach my $l (@$lines) {
      print $l;
    }
    return 1;
  };

  return $self->{renderer};
}

1;
