package ResultsSystem::View;

use strict;
use warnings;

use CGI;
use HTTP::Response;
use HTTP::Status qw/:constants status_message/;

use JSON::Tiny qw(decode_json encode_json);

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

=head2 render

=cut

sub render {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $response = HTTP::Response->new( HTTP_OK,
    status_message(HTTP_OK),
    [ 'Content-Type' => 'text/html; charset=ISO-8859-1',
      'Status'       => HTTP_OK . " " . status_message(HTTP_OK)
    ],
    $data
  );

  print $response->headers->as_string . "\n\n";
  print $response->content . "\n";

}

=head2 render_javascript

=cut

sub render_javascript {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $response = HTTP::Response->new( HTTP_OK,
    status_message(HTTP_OK),
    [ 'Content-Type' => 'text/javascript; charset=ISO-8859-1',
      'Status'       => HTTP_OK . " " . status_message(HTTP_OK)
    ],
    $data
  );

  print $response->headers->as_string . "\n\n";
  print $response->content . "\n";

}

=head2 render_json

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

}

=head2 merge_content

=cut

sub merge_content {
  my ( $self, $html, $data ) = @_;

  foreach my $k ( keys %$data ) {

    # $html =~ s/[% $k %]/$data->{$k}/xmsg;
    $html =~ s/\[%\s$k\s%\]/$data->{$k}/xmsg;
  }

  return $html;
}

=head2 merge_array

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

=cut

sub html_frame_wrapper {
  my $self = shift;

  my $output = q{
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

<title>PAGETITLE</title>
<style type='text/css'>
<!--
\@import url(gen_styles.css);
-->
</style>

<script language="JavaScript" type="text/javascript" src="/results_system/common/common.js"></script>

</head>
  [% CONTENT %]
</html>
};
  return $output;
}

=head2 html_wrapper

=cut

sub html_wrapper {
  my $self = shift;

  my $q = CGI->new();

  my $output = q{
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
<style type='text/css'>
<!--
\@import url(gen_styles.css);
-->
</style>

<script language="JavaScript" type="text/javascript" src="/results_system/common/common.js"></script>

</head>
  <body>
  [% CONTENT %]
  </body>
</html>
};

  return $output;
}

1;
