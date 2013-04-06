=head1 NAME

Fcerror Package

=head1 SYNOPSIS

Perl module to store and process error messages.

=cut

#************************************************************************
#
# Name: Fcerror
#
# Function: Package to enhance the handling of error messages. The Fcerror
#       object stores the error messages and their debug level in an array
#       of objects.
#       These can then be retrieved individually or dumped en masse.
#
#       Constructor: new Fcerror()
#
#       Methods:
#         Add(message, debug_level) Add a message to the list
#         Dump() Send all the messages to the standard output provided the
#         debug level is within limits. Does not delete the messages.
#         Clear() Deletes all the messages
#         PopOne() Returns the first message and deletes it.
#         AppendTo(objectref) Appends all the messages to the Fcerror object 
#         passed by reference as argument 1.
#         Append(objectref) Append the error object passed by ref to the list.
#         GetLast() returns the last message without deleting it.
#
# 12.0 - 10 Oct 06 - Limit message queue size. Use round robin.
# 14.0 - 16 Nov 06 - Add eInit() to eDump() so that eDump doesn't fail if 
#                    there are no messages.
# 14.1 - 03 Dec 06 - eSetMaxMsgs added.
# 15.0 - 11 May 07 - POD improved.
# 16.0 - 11 Oct 08 - This has been modified since 11 May 07!
# 17.0 - 25 Oct 09 - Re-written to use an array instead of a series of hashes.
# 17.1 - 31 Oct 09 - Truncate messages to 1000 characters by default.
#
#************************************************************************
{ package Fcerror;
#************************************************************************

  use strict;
  
=head2 Errormsg Object

Object which holds an error message and it's debug level.

=cut

  #*************************
  { package Errormsg;
  #*************************
    
=head3 Constructor

Accepts 2 arguments. 1) The message. 2) The debug level. 0 = Low priority.

=cut

use strict;

    #*************************
    sub new
    #*************************
    {
      my $self={};
      my $class = shift;
      bless($self, $class);
      $self->{MSG} = shift;
      $self->{DBGLEVEL} = shift;
      return $self;
    }

=head3 GetMsg()

Method which returns the error message.

=cut

    #*************************
    sub GetMsg
    #*************************
    {
      my $self = shift;
      return $self->{MSG};
    }

=head3 GetLevel()

Method which returns the debug level. 0 = Low priority.

=cut

    #*************************
    sub GetLevel
    #*************************
    {
      my $self = shift;
      return $self->{DBGLEVEL};
    }
  } # End package Errormsg

=head2 Fcerror Object

=head3 Constructor For Fcerror Object

Create the object. No arguments.

=cut

  #*************************
  sub new
  #*************************
  {
    my $self={};
    bless($self);
    $self->{MSGS} = [];
    $self->{MINDEBUG}=0;
    $self->{MAXDEBUG}=10;
    $self->SetPretty(0);
    $self->{PRETTYDEPTH}=0;
    $self->{MAXMSGS} = 1000;
    $self->{MAXMSGLENGTH} = 1000; # Characters.
    return $self;
  } # End new() 

=head3 Add

Method which adds an error to the list of errors by creating a new errormsg object
and adding it to the end of an array of errormsg objects.

3 arguments. 1) Message 2) Debug level. 0 = Low priority. 3) Do not truncate message length.

=cut

  #*************************
  sub Add
  #*************************
  {
    my ( $self, $msg, $lev, $notrunc ) = ( @_ );
    $msg=~s/\n/ /g;
    if ( $lev !~ m/^\d+$/ ) {
      $self->Add( "The debug level was not an integer. Set it to 2.", 2 );
      $lev = 2;
    }
    $msg = substr( $msg, 0, $self->{MAXMSGLENGTH} ) if ! $notrunc;
    if ( ( $msg ) && ( $lev =~ m/^[0-9]{1,}$/ ) ) {
      push @{$self->{MSGS}}, new Errormsg($msg, $lev);
    }
    if ( scalar( $self->get_msgs ) > $self->GetMaxMsgs ) {
      $self->PopOne;
    }  
    return 0;
  } 

  sub get_msgs {
    my $self = shift;
    return @{$self->{MSGS}};
  }
  
=head3 Dump

Method which returns all the error messages as a single string. The messages are
separated by carriage returns.

The debug level must be between the minimum and maximum levels inclusive.

=cut

 #*************************
  sub Dump
  #*************************
  {
    my $self = shift;
    my $lev;
    my $text;
    my @msgs = $self->get_msgs;
    foreach my $m ( @msgs ) {
      $lev = $m->GetLevel();
      if ($lev >= $self->{MINDEBUG} && $lev <= $self->{MAXDEBUG})
      {
        $text = $text . $self->PrettyIndent($m->GetMsg(), $lev) . $m->GetMsg() . "\n";
      }
    }
    return $text;
  }

=head3 Clear

Delete all messages.

=cut

  #*************************
  sub Clear
  #*************************
  {
    my $self = shift;
    $self->{MSGS} = [];
  }

=head3 AppendTo

  Append the error messages to the Fcerror
  object passed by reference as argument 1.

=cut

  #*************************
  # Append the error messages to the Fcerror
  # object passed by reference as argument 1.
  #*************************
  sub AppendTo
  #*************************
  {
    my $self = shift;
    my $errorref = shift; # Fcerror object reference
    my $obj = $$errorref;
    
    $obj->Append( $self, "noclear" );
  } # End AppendTo()

=head3 Append

Accepts a reference to an error object. Appends the messages of this object
to it's own list. PopOne() is used, so the object passed as
an argument is permanently altered.

=cut

  #*************************
  sub Append
  #*************************
  {
    my $self = shift;
    my $errorref = shift; # Fcerror object reference
    my $noclear = shift;
    my $error;
    
    my $object = ref( $errorref );
    if ( $object =~ m/Fcerror/i ) {
      # $self->Add( "Append() has been passed an Fcerror object.", 1 );
      $error = $errorref;
    }
    elsif ( ref( $$errorref ) =~ m/Fcerror/i ) {
      # $self->Add( "Append() has been passed a reference to an Fcerror object.", 1 );
      $error = $$errorref
    }
    else {
      $self->Add( "Append() has been passed a parameter for which ref() returns: " . $object, 1 );
      return;
    }

    die "Can't append an object to itself." if $error == $self;
    
    push @{$self->{MSGS}}, $error->get_msgs;
    #while ( scalar( @{$self->{MSGS}} ) > $self->GetMaxMsgs ) {
    #  $self->PopOne;
    #}
    splice @{$self->{MSGS}}, 0, scalar( @{$self->{MSGS}} ) - $self->GetMaxMsgs;
    $error->Clear if ! $noclear;
    
  } # End Append

=head3 PopOne

Return the first message and delete it from the list. Returns
two values, the message and the level.

e.g. ($msg, $lev) = $e->PopOne();

Both values will be null if the list is empty.

Ignores max and min debug level.

=cut

  #*************************
  sub PopOne
  #*************************
  {
    my $self = shift;
    my $m = shift @{$self->{MSGS}};
    return $m ? ($m->GetMsg, $m->GetLevel) : ( undef, undef );
  }

=head3 GetLast

Return the last message without deleting it. Returns the message
text, not the level.

Ignores max and min debug level.

=cut

  #*************************
  # Return the last message without deleting it.
  #*************************
  sub GetLast
  #*************************
  {
    my $self = shift;
    my @msgs = $self->get_msgs;
    my $l = scalar( @msgs ) - 1;
    return $l >= 0 ? $msgs[$l]->GetMsg : undef;
  }

=head3 SetMaxDebug

=cut

  #*************************
  sub SetMaxDebug
  #*************************
  {
    my $self = shift;
    my $lev =shift;
    if ($lev=~m/^[0-9]{1,}$/)
    {
      if ($lev >= $self->{MINDEBUG})
      {
        $self->{MAXDEBUG}=$lev;
      }
      else
      {
        $self->Add("SetMaxDebug() " . $lev . " < " . $self->GetMinDebug(), $self->GetMinDebug());
      }  
    }
  }

=head3 SetMinDebug

=cut

  #*************************
  sub SetMinDebug
  #*************************
  {
    my $self = shift;
    my $lev =shift;
    if ($lev=~m/^[0-9]{1,}$/)
    {
      if ($lev <= $self->{MAXDEBUG})
      {
        $self->{MINDEBUG}=$lev;
      }
      else
      {
        $self->Add("SetMinDebug() " . $lev . " > " . $self->GetMaxDebug(), $self->GetMinDebug());
      }  
    }
  }

=head3 GetMinDebug

=cut

  #*************************
  sub GetMinDebug
  #*************************
  {
    my $self = shift;
    return    $self->{MINDEBUG};
  }

=head3 GetMaxDebug

=cut

  #*************************
  sub GetMaxDebug
  #*************************
  {
    my $self = shift;
    return $self->{MAXDEBUG};
  }

=head3 GetClone

=cut

  #*************************
  sub GetClone
  #*************************
  {
    my $self = shift;
    my $copy = { %$self };
    bless $copy, ref $self;
    return $copy;
  }

=head3 SetPretty

=cut

  #*************************
  sub SetPretty
  #*************************
  {
    my $self = shift;
    my $on = shift;
    if ($on == 1) { $self->{PRETTY} = 1; }
    else { $self->{PRETTY} = 0; }
  }

=head3 GetPretty

=cut

  #*************************
  sub GetPretty
  #*************************
  {
    my $self = shift;
    return $self->{PRETTY};
  }  

=head3 PrettyIndent

This is called from Dump(). When Pretty is set to 1 it attempts to indent the dump messages
to show the subroutine call level.

Relies on each subroutines having an entry message of the form "Starting xxxxxx():" and
an exit message of the form "Leaving xxxxxx():".

The indent is increased in increments of 2 spaces.

=cut

  #*************************
  sub PrettyIndent
  #*************************
  {
    my $self = shift; my $msg = shift; my $lev = shift; my $x = 0; my $indent="";
    my $indentstr = "  ";
 
    if ($self->GetPretty()==1 && $lev >= $self->{MINDEBUG} )
    {
      # print "Pretty enabled\n";
      if ($msg=~m/^Starting.*\(\):/) { $self->{PRETTYDEPTH}++; }
      for ($x=1; $x< $self->{PRETTYDEPTH}; $x++)
      {
        $indent = $indent . $indentstr;
      }
      if ($msg=~m/^Leaving.*\(\):/ && $self->{PRETTYDEPTH} > 0) { $self->{PRETTYDEPTH}--; }
    
      while ($x < $lev) { $indent = $indent . $indentstr; $x++; }
    }  
    return $indent;
  }


=head3 SetMaxMsgs
  
  Set the maximum size of the message list. This is not meant to be 
  dynamically modified. Set it once soon after creating the object.
  
  Defaults to 1000.
  
=cut

  #*************************
  sub SetMaxMsgs
  #*************************
  {
    my $self = shift;
    if ( $self->{MAXMSGS} > 0 )
    {
      $self->{MAXMSGS} = shift;
    }
  }  
  
=head3 GetMaxMsgs
  
  Return the maximum size of the message list.
  
=cut

  #*************************
  sub GetMaxMsgs
  #*************************
  {
    my $self = shift;
    return $self->{MAXMSGS};
  }  
  
  1;
} # End package Fcerror

#*********************************************************
# This is a wrapper package which allows an object to inherit
# error handling functions. In order to use these, the object
# must require Fcerror and include Fcwrapper in it's @ISA
# list.
#*********************************************************
{ package Fcwrapper;
#*********************************************************

=head3 Fcwrapper

This is a wrapper package which allows an object to inherit
error handling functions. In order to use these, the object
must require Fcerror and include Fcwrapper in it's @ISA
list.

=over 5

=item eInit

=item eAdd

=item eSetMinDebug

=item eSetMaxDebug

=item eGetMinDebug

=item eGetMaxDebug

=item eSetPretty

=item eDump

=item eClear

=item eGetError

=item eAppend

=item eGetClone

=item eSetMaxMags

=item eSet

=back

=cut

  #*************************************
  sub eInit
  #*************************************
  {
    my $self = shift;
    if (! $self->{ERROR})
    {
      $self->{ERROR} = new Fcerror();
    }
    return 0;
  }
  
  #*************************************
  sub eAdd
  #*************************************
  {
    my ( $self, @a ) = ( @_ );
    $self->eInit();
    return $self->{ERROR}->Add(@a);  
  }

  #*************************************
  sub eSetMinDebug
  #*************************************
  {
    my $self=shift; my @a=@_;
    $self->eInit();
    $self->{ERROR}->SetMinDebug(@a);
  }
  
  #*************************************
  sub eSetMaxDebug
  #*************************************
  {
    my $self=shift; my @a=@_;
    $self->eInit();
    $self->{ERROR}->SetMaxDebug(@a);
  }

  #*************************************
  sub eGetMinDebug
  #*************************************
  {
    my $self=shift;
    return $self->{ERROR}->GetMinDebug();
  }
  #*************************************
  sub eGetMaxDebug
  #*************************************
  {
    my $self=shift;
    return $self->{ERROR}->GetMaxDebug(@a);
  }
  
  #*************************************
  sub eSetPretty
  #*************************************
  {
    my $self=shift; my @a=@_;
    $self->eInit();
    $self->{ERROR}->SetPretty(@a);
  }

  #*************************************
  sub eDump
  #*************************************
  {
    my $self=shift; my @a=@_;
    $self->eInit();
    return $self->{ERROR}->Dump(@a);
  }
  
  #*************************************
  sub eClear
  #*************************************
  {
    my $self=shift; my @a=@_;
    return $self->{ERROR}->Clear() if $self->{ERROR};
  }
  
  #*************************************
  sub eGetError
  #*************************************
  {
    my $self=shift; my @a=@_;
    $self->eInit();
    return $self->{ERROR};
  }

  #*************************************
  sub eAppend
  #*************************************
  {
    my $self=shift; my $o = shift;
    $self->eInit;
    return $self->{ERROR}->Append($o);
  }

  #*************************************
  sub eGetClone
  #*************************************
  {
    my $self=shift; my @a=@_;
    return $self->{ERROR}->GetClone(@a);
  }

  #*************************************
  sub eSetMaxMsgs
  #*************************************
  {
    my $self=shift; my @a=@_;
    $self->eInit();
    $self->{ERROR}->SetMaxMsgs( @a );
  }

  # Make this object use an existing Fcerror object.
  #*************************************
  sub eSet {
  #*************************************
    my ( $self, $e, $force ) = ( @_ );
    if ( ! $e ) {
      $self->eAdd( "The argument to eSet() is missing.", 5 );
      return 1;
    }  
    elsif ( ref( $e ) !~ m/Fcerror$/ ) {
      $self->eAdd( "The argument to eSet() must be an Fcerror object.", 5 );
      return 1;
    }
    elsif ( $self->{ERROR} && ! $force ) {
      $self->eAdd( "The error object is already set. Use 'force' to over-write.", 5 );
      return 1;
    }
    else {
      $self->{ERROR} = $e;
    }
    return 0;
  }
  
  1;
} # End package Fcwrapper
