  package ResultsSystem::View::Pwd;

  use strict;
  use warnings;
  use parent qw/ ResultsSystem::View /;

  use Data::Dumper;

=head1 NAME

ResultsSystem::View::Pwd

=cut

=head1 SYNOPSIS

Object which facilitates password handling.

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::View

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

Constructor for the Pwd object. Accepts -config and -query arguments.

=cut

  #***************************************
  sub new {

    #***************************************
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    return $self;
  }

=head2 get_pwd_fields

Returns the HTML for a table containing 1 row and 2 cells. The first cell
contains the user input field, the second contains the passwords input fields. 

The id and name attributes are the same and are set to "user" and "code" respectively.

=cut

  #***************************************
  sub get_pwd_fields {

    #***************************************
    my $self = shift;
    return $self->get_html;
  }

=head2 get_html

=cut

  sub get_html {
    my $self = shift;
    return <<'HTML';
	  <table>
	  <tr><td>User:</td>
	  <td><input type="text" size="20" name="user" id="user"/><td>
	  <tr><td>Code:</td>
	  <td><input type="password" size="20" name="code" id="code"/><td>
	  </tr>
	  </table>
HTML
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

  1;
