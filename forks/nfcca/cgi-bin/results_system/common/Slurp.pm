{ package Slurp;

  use Exporter;
  @ISA = qw( Exporter );
  @EXPORT = qw( slurp );
  
  sub slurp {
    my $f = shift;
    my ( $FP, @lines );
    
    if ( -f $f ) {
    
      open $FP, $f;
      while ( <$FP> ) {
      
        push @lines, $_;
        
      }
      close $FP;
    }
    return @lines;
  }

  1;
  
}