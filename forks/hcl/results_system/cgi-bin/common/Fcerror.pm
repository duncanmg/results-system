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
    $self->{FIRST}=0;
    $self->{LAST}=0;
    $self->{MINDEBUG}=0;
    $self->{MAXDEBUG}=10;
    $self->SetPretty(0);
    $self->{PRETTYDEPTH}=0;
    $self->{MAXMSGS} = 1000;
    return $self;
  } # End new() 

=head3 Add

Method which adds an error to the list of errors by creating a new errormsg object
and adding it to the end of an array of errormsg objects.

2 arguments. 1) Message 2) Ddebug level. 0 = Low priority.

=cut

  #*************************
  sub Add
  #*************************
  {
    my $self = shift;
    my $msg = shift;
    my $lev = shift; # Debug level. May be null
    $msg=~s/\n/ /g;
    if ( ( $msg ) && ( $lev =~ m/^[0-9]{1,}$/ ) ) {
      my $n = $self->GetNextMsgNo();
      $self->{$n} = new Errormsg($msg, $lev);
    }  
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
    my $x = $self->{FIRST};
    my $lev;
    my $text;
    while ($x != $self->{LAST})
    {
      $lev = $self->{$x}->GetLevel();
      if ($lev >= $self->{MINDEBUG} && $lev <= $self->{MAXDEBUG})
      {
        $text = $text . $self->PrettyIndent($self->{$x}->GetMsg(), $lev) . $self->{$x}->GetMsg() . "\n";
      }
      $x = $self->ReadNextMsgNo($x);
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
    $self->{FIRST}=0;
    $self->{LAST}=0;
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
    my $x = $self->{FIRST};
    while ($x != $self->{LAST})
    {
      $$errorref->Add($self->{$x}->GetMsg(), $self->{$x}->GetLevel()) ;
      $x = $self->ReadNextMsgNo($x);
    }
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
    my $more=1;
    my $error;
    my ( $msg, $lev );
    
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
    
    while ($more==1)
    {
      ($msg, $lev) = $error->PopOne();
      # print $more . " " . $msg . " ";
      if ($msg)
      { $self->Add($msg, $lev); }
      else { $more=0; }
    }
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
    my $msg; my $lev;
    
    # print "Before: " . $self->{FIRST} . " " . $self->{LAST} . "<br/>\n";
    if ($self->{FIRST} != $self->{LAST})
    {
      $msg = $self->{$self->{FIRST}}->GetMsg();
      $lev = $self->{$self->{FIRST}}->GetLevel();
      $self->{FIRST} = $self->ReadNextMsgNo($self->{FIRST});
    }
    # print "After: " . $self->{FIRST} . " " . $self->{LAST} . "<br/>\n";
    return ($msg, $lev);
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
    my $err=0;
    my $msgno = $self->{LAST} - 1;
    if ( $self->{LAST} == $self->{FIRST} )
    {
      # Queue is empty.
      $err = 1;
    }
    elsif ( $self->{LAST} == 0 )
    {
      $msgno = $self->GetMaxMsgs;
    }
    if ( $err == 0 )
    {
      return $self->{$msgno}->GetMsg();
    }  
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

=head3 GetNextMsgNo
  
  Return the next message number on a round robin basis. Once
  the maximum is reached it loop back round to 0.
  
  Internal use only.
  
=cut

  #*************************
  sub GetNextMsgNo
  #*************************
  {
    my $self = shift;
    my $n = $self->{LAST};
    $self->{LAST}++;
    if ( $self->{LAST} > $self->{MAXMSGS} )
    {
      $self->{LAST} = 0;
    }
    if ( $self->{LAST} == $self->{FIRST} )
    {
      $self->{FIRST}++;
    }
    if ( $self->{FIRST} > $self->{MAXMSGS} )
    {
      $self->{FIRST} = 0;
    }
    return $n;
  }

=head3 ReadNextMsgNo
  
  Return the next message number after the one passed as an argument 
  on a round robin basis. Once the maximum is reached it loops back round to 0.
  
  e.g. $x->ReadNextMsgNo(100) returns 101 if the maximum number of messages
  is set to greater than 100. If the maximum number of messages is set to
  100 or less then it will return 0.

  Internal use only.
  
=cut

  #*************************
  sub ReadNextMsgNo
  #*************************
  {
    my $self = shift;
    my $num = shift;
    
    $num++;
    if ( $num > $self->{MAXMSGS} )
    {
      $num = 0;
    }
    return $num;
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
  }
  
  #*************************************
  sub eAdd
  #*************************************
  {
    my $self=shift;
    my @a = @_;
    $self->eInit();
    $self->{ERROR}->Add(@a);  
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

  1;
} # End package Fcwrapper
