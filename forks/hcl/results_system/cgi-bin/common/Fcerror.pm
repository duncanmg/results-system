
#*********************************************************
# This is a wrapper package which allows an object to inherit
# error handling functions. In order to use these, the object
# must require Fcerror and include Fcwrapper in it's @ISA
# list.
#*********************************************************
{

  package Fcwrapper;

  use Logger;

  sub logger {
    if ( !$self->{logger} ) {
      $self->{logger} = Logger::get_logger("Fcw");
    }
    return $self->{logger};
  }

  1;
}    # End package Fcwrapper
