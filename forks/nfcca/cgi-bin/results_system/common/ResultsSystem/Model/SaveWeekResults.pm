  package ResultsSystem::Model::SaveWeekResults;

  use strict;
  use warnings;

  use Params::Validate qw/:all/;

  use parent qw/ ResultsSystem::Model /;

=head1 NAME

ResultsSystem::ResultsSystem::Model::SaveWeekResults

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

Constructor for the WeekResults object. Inherits arguments from Parent
plus -division and -week.

=cut

  #***************************************
  sub new {

    #***************************************
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    my %args = (@_);

    if ( $args{-division} ) {
      $self->set_division( $args{-division} );
    }
    if ( $args{-week} ) {
      $self->set_week( $args{-week} );
    }

    return $self;
  }

=head2 get_labels

=cut

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
    my ( $self, $lines ) = validate_pos( @_, 1, { type => ARRAYREF } );

    my @labels = $self->get_labels;

    my $ff = $self->get_full_dat_filename;

    # my $lines = $self->get_lines;
    return if !scalar @$lines;

    my $out = [];
    foreach my $line (@$lines) {

      $line = $self->validate_line($line);

      push @$out, join( ",", map { $line->{$_} } @labels );

    }

    open( my $FP, ">", $ff ) || do {
      $self->logger->error("WeekResults(): Unable to open file for writing. $ff.");
      return;
    };

    print $FP join( "\n", @$out );
    close($FP) if $FP;

    return 1;
  }

=head2 validate_line

=cut

  sub validate_line {
    my ( $self, $line ) = validate_pos( @_, 1, { type => HASHREF } );

    my @labels = $self->get_labels;
    foreach my $label (@labels) {

      if ( $label =~ m/(team)|(played)|(result[^p])|(performances)/x ) {
        $line->{$label} =~ s/[,<>|\n]/ /xg;
        $line->{$label} ||= "";
      }
      else {
        $line->{$label} =~ s/[^\d-]//xg;
        $line->{$label} ||= 0;
      }
    }
    return $line;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

  1;
