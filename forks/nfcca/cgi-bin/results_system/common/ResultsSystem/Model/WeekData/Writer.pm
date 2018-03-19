  package ResultsSystem::Model::WeekData::Writer;

  use strict;
  use warnings;
  use Data::Dumper;
  use Params::Validate qw/:all/;

  use parent qw/ ResultsSystem::Model::WeekData /;

=head1 NAME

ResultsSystem::Model::WeekData::Writer

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model::WeekData

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 write_file

This writes the current contents of the data structure to the results file for the division and week.

=cut

  #***************************************
  sub write_file {

    #***************************************
    my ( $self, $lines ) = validate_pos( @_, 1, { type => ARRAYREF } );

    $self->logger->debug('write_file');

    my @labels = $self->get_labels;

    my $ff = $self->get_full_dat_filename;

    $self->logger->debug( 'division ' . $self->get_division );
    $self->logger->debug( 'full_dat_filename ' . $ff );

    # my $lines = $self->get_lines;
    return if !scalar @$lines;

    my $out = [];
    foreach my $line (@$lines) {

      $line = $self->validate_line($line);

      push @$out, join( ",", map { $line->{$_} } @labels );

    }

    open( my $FP, ">", $ff ) || do {
      $self->logger->error("WeekData(): Unable to open file for writing. $ff.");
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

      if ( $label =~ m/^(team)|(played)|(result[^p]*)|(performances)$/x ) {
        $line->{$label} ||= "";
        $line->{$label} =~ s/[,<>|\n]/ /xg;
      }
      else {
        $line->{$label} ||= 0;
        $line->{$label} =~ s/[^\d-]//xg;
      }
    }
    return $line;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

  1;
