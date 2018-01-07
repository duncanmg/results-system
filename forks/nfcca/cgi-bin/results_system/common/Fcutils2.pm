#************************************************************************
#
# 0.1  - 20 May 08 - Created from Fcutils
# 0.2  - 01 Feb 09 - Remove fcGlobals.pm
#
#************************************************************************

=head1 NAME

Fcutils2 Package

=cut

=head1 SYNOPSIS

Utilities.

=cut

=head1 METHODS AND FUNCTIONS

=cut

#***********************************************************************
#
# Name Fcutils2.pm
#
#***********************************************************************

{

  package Fcutils2;

  use strict;

  use FcLockfile;
  use Logger;

=head2 External Methods

=cut

=head3 Constructor

Create the object and gives it an error object. Binds in the current values of
the class variables LOGDIR, OLDFILE.

=cut

  #*****************************************************************************
  sub new

    #*****************************************************************************
  {
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    my $err = 0;
    return $self;

  }    # End constructor

=head3 get_locker

=cut

  sub get_locker {
    my ( $self, %args ) = @_;
    if ( !$self->{LOCKER} ) {
      $self->{LOCKER} = FcLockfile->new( %args || () );
    }
    return $self->{LOCKER};
  }

=head3 get_logger

=cut

  sub get_logger {
    my ( $self, %args ) = @_;
    $self->{LOGGER} = Logger->new( %args || () );
    return $self->{LOGGER};
  }

=head2 Internal Methods

=cut

  1;
}    # End package Fcutils
