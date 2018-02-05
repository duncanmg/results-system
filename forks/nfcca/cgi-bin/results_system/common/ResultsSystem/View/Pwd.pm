# *************************************************************
#
# Name: Pwd.pm
#
# 0.1  - 25 Jun 08 - POD added.
#
# *************************************************************

  package ResultsSystem::View::Pwd;

  use strict;
  use warnings;
  use parent qw/ ResultsSystem::View /;

  use Data::Dumper;

=head1 Pwd

Object which facilitates password handling.

=cut

=head2 External Methods

=cut

=head3 new

Constructor for the Pwd object. Accepts -config and -query arguments.

=cut

  #***************************************
  sub new {

    #***************************************
    my $class = shift;
    my $self = {};
    bless $self, $class;

    return $self;
  }

=head3 get_pwd_fields

Reurns the HTML for a table containing 1 row and 2 cells. The first cell
contains the user input field, the second contains the passwords input fields. 

The id and name attributes are the same and are set to "user" and "code" respectively.

=cut

  #***************************************
  sub get_pwd_fields {

    #***************************************
    my $self = shift;
    my $line;
    my $q = $self->get_query;

    $line = $q->td("User:") . "\n";
    $line =
        $line
      . $q->td( $q->input( { -type => "text", -size => 20, -name => "user", -id => "user" } ) )
      . "\n";
    $line = $line . $q->td("Code:") . "\n";
    $line =
      $line
      . $q->td(
      $q->input( { -type => "password", -size => 20, -name => "code", -id => "code" } ) )
      . "\n";
    $line = $q->Tr($line) . "\n";
    $line = $q->table($line) . "\n";

    return $line;
  }

  1;
