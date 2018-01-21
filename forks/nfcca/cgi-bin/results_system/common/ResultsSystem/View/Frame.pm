package ResultsSystem::View::Frame;

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

# TODO print $q->header( -expires => "+2d" );

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $html = $self->get_html;

  foreach my $k ( keys %$data ) {
    $html =~ s/$k/$data->{$k}/xmsg;
  }

  $self->render({-data=>$html});
}

=head2 get_html

=cut

sub get_html {

  my $output = qq{
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
           "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">


<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US">
<head>
<!--***************************************************************
*
* Name: results.htm
*
* Function:
*
*       Copyright Duncan Garland Consulting Ltd 2003. All rights reserved.
*
* 23 Feb 08 - HTML validated.
* 20 Jun 08 - No longer displayed directly. Pre-processed through results_system.pl?page=frame
*             MENU_PAGE is replaced with the correct call.
*
****************************************************************-->

<title>TITLE</title>
<style type='text/css'>
<!--
\@import url(gen_styles.css);
-->
</style>

<script language="JavaScript" type="text/javascript" src="/results_system/common/common.js"></script>

</head>


  <frameset rows="30%,*">
  <frame noresize="noresize" src="MENU_PAGE" id = "f_menu"
    name="f_menu" scrolling="auto"></frame>
  <frame scrolling="auto" src="BLANK_PAGE" id = "f_detail" name="f_detail"></frame>
  <noframes>
  <body>
  You do not appear to have a frames capable browser.
  </body>
  </noframes>
  </frameset>

</html>
};

}
1;
