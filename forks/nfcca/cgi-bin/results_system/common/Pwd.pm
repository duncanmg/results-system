# *************************************************************
#
# Name: Pwd.pm
#
# 0.1  - 25 Jun 08 - POD added.
#
# *************************************************************

{ package Pwd;

  use strict;
  use CGI;
  
  use Parent;
  use Fcutils2;
  
  our @ISA;
  unshift @ISA, "Parent";

=head1 Pwd

Object which facilitates password handling. Inherits from Parent.pm and uses
the password methods of the Fcutils2 object.

=cut

=head2 new

Constructor for the Pwd object. Accepts -config and -query arguments.

=cut

  #***************************************
  sub new {
  #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = ( @_ );
    
    $self->initialise( \%args );
    $self->eAdd( "Pwd object created.", 1 );
    
    return $self;
  }

=head2 get_pwd_fields

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
    
    $line = $q->td( "User:" ) . "\n";
    $line = $line . $q->td( $q->input( { -type => "text", -size => 20, -name => "user", -id => "user" } ) ) . "\n";
    $line = $line . $q->td( "Code:" ) . "\n";
    $line = $line . $q->td( $q->input( { -type => "password", -size => 20, -name => "code", -id => "code" } ) ) . "\n";
    $line = $q->Tr( $line ) . "\n";
    $line = $q->table( $line ) . "\n";
    
    return $line;
  }

=head2 check_pwd

This method interrogates the query object and retrieves the user and code parameters.
It then reads the correct password for the user from the ResultsConfiguration object.

It uses the CheckCode method of the Fcutils2 object to compare the two codes.

It returns an error code (0 for success) and a message.

 ( $err, $msg ) = $p->check_pwd();
 if ( $err != 0 ) {
   print $msg . "\n";
 }  

=cut

  #***************************************
  sub check_pwd {
  #***************************************
    my $self = shift;
    my $err = 1;
    my $q = $self->get_query;
    my $c = $self->get_configuration;
    
    my $u = Fcutils2->new();
    $u->set_pwd_dir( $c->get_path( -pwd_dir => "Y" ) );
    
    my $msg;
    
    my $user = $q->param( "user" );
    my $code = $q->param( "code" );
    my $real = $c->get_code( $user );
    if ( ! $real ) {
      $self->eAdd( "No password for user $user.", 5 );
      $err = 1;
    }
    else {
      ( $err, $msg ) = $u->CheckCode( $real, $code, $user );
    }  
    $self->eAppend( $u->eGetError );
    
    return ( $err, $msg );
    
  }
  
  1;
}