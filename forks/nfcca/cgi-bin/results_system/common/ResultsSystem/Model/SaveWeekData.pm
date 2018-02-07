  package ResultsSystem::Model::SaveWeekData;

  use strict;
  use warnings;

  use Params::Validate qw/:all/;

  use parent qw/ ResultsSystem::Model /;

=head1 WeekData.pm

=cut

=head1 Methods

=cut

=head2 new

Constructor for the WeekData object. Inherits arguments from Parent
plus -division and -week.

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    if ( $args{-division} ) {
      $self->set_division( $args{-division} );
    }
    if ( $args{-week} ) {
      $self->set_week( $args{-week} );
    }

    return $self;
  }

  #***************************************
  sub get_labels {

    #***************************************
    my $self = shift;

    my @list = (
      "team",       "played",       "result",    "runs",
      "wickets",    "performances", "resultpts", "battingpts",
      "bowlingpts", "penaltypts",   "totalpts",  "pitchmks",
      "groundmks",  "facilitiesmks"
    );

    return @list;
  }

=head2 write_file

This writes the current contents of the data structure to the results file for the division and week.

=cut

  #***************************************
  sub write_file {

    #***************************************
    my ($self,$lines) = validate_pos(@_,1,{type=>ARRAYREF});
    my $FP;

    my @labels = $self->get_labels;

    my $ff = $self->get_full_dat_filename;

    
    # my $lines = $self->get_lines;
    return if ! scalar @$lines;

      open( $FP, ">", $ff ) ||do {
        $self->logger->error("WeekData(): Unable to open file for writing. $ff.");
        return;
      };

      foreach my $line ( @$lines ) {

        $line = $self->validate_line($line);

        my $out = join(",", map { $line->{$_} } @labels );
          print $FP $out . "\n";

      }

      close ($FP) if $FP;

    return 1;
  }

=head2 validate_line

=cut

  sub validate_line {
     my($self,$line)=validate_pos(@_, 1, {type=>HASHREF});

     my @labels = $self->get_labels;
     foreach my $label (@labels) {

        if ($label =~ m/(team)|(played)|(result[^p])|(performances)/ ) {
          $line->{$label} =~ s/[,<>|\n]/ /g;
          $line->{$label} ||="";
        }
        else {
            $line->{$label} =~ s/[^\d-]//g;
            $line->{$label} ||=0;
        }
    }
    return $line;
  }

  1;
