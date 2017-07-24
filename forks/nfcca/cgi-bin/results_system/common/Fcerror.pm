
#*********************************************************
# This is a wrapper package which allows an object to inherit
# error handling functions. In order to use these, the object
# must require Fcerror and include Fcwrapper in it's @ISA
# list.
#*********************************************************
{

  package Fcwrapper;

  use Logger;
  use DateTime::Tiny;
  use Clone qw/ clone /;

=head2 logger

$self->logger->debug( "Use the existing logger if there is one." );

$self->logger(1)->debug( "Always use a new logger." );

=cut

  sub logger {
    my ( $self, $force ) = @_;
    if ( $force || !$self->{logger} ) {
      my $class = ref( $self );
      $self->{logger} = Logger::get_logger( $class, $self->logfile_name );
    }
    return $self->{logger};
  }

=head2 logfile_name

Return the existing logfile_name or undef:

$self->logfile_name();

Set the logfile_name and use the given directory:

If called on 28 Apr 2013

my $logfile_name = $self->logfile_name( "/tmp" );

will set $logfile_name to "/tmp/rs28.log"

=cut

  sub logfile_name {
    my ( $self, $dir ) = @_;
    my $now = DateTime::Tiny->now();
    if ($dir) {
      $self->{logfilename} = sprintf( "%s/%s%02d.log", $dir, "rs", $now->day );
      # $self->delete_old_logfile( $now, $dir );
    }
    return $self->{logfilename};
  }

#  sub delete_old_logfile {
#	  my ( $self, $date, $dir ) = @_;
#	  my $tomorrow = clone $date;
#	  $tomorrow->add( days => 1 );
#	  $file = sprintf( "%s/%s%02d.log", $dir, "rs", $tomorrow->day );
#	  if ( -f $file ) {
#		  unlink( $file ) || print STDERR $! . "\n";
#	  }
#	  return 1;
#  }

  1;

}    # End package Fcwrapper
