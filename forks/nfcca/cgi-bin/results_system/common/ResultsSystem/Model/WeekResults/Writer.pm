  package ResultsSystem::Model::WeekResults::Writer;

  use strict;
  use warnings;
  use Data::Dumper;
  use Params::Validate qw/:all/;
  use ResultsSystem::Exception;

  use parent qw/ ResultsSystem::Model::WeekResults /;

=head1 NAME

ResultsSystem::Model::WeekResults::Writer

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model::WeekResults|http://www.results_system_nfcca.com:8088/ResultsSystem/Model/WeekResults>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 write_file

This writes the current contents of the data structure to the results file for the division and week.

Gets the filename using get_full_filename().

Logs an error and returns undef if the file cannot be opened.

Returns true on success.

=cut

  #***************************************
  sub write_file {

    #***************************************
    my ( $self, $lines ) = validate_pos( @_, 1, { type => ARRAYREF } );

    $self->logger->debug('write_file');

    my @labels = $self->get_labels;

    my $ff = $self->get_full_filename;

    if ( !$ff ) {
      $self->logger->error('full_filename is not set');
      croak ResultsSystem::Exception->new( 'FILENAME_NOT_SET', 'full_filename is not set' );
    }

    return if !scalar @$lines;

    my $out = [];
    foreach my $line (@$lines) {

      $line = $self->validate_line($line);

      push @$out, join( ",", map { $line->{$_} } @labels );

    }

    open( my $FP, ">", $ff ) || do {
      $self->logger->error("WeekResults::Writer(): Unable to open file for writing. $ff.");
      croak ResultsSystem::Exception->new( 'FILENAME_NOT_WRITEABLE',
        "Unable to open file for writing. $ff" );
    };

    print $FP join( "\n", @$out );
    close($FP) if $FP;

    return 1;
  }

=head2 validate_line

Accepts a hashref which represents a line of table and validates the keys.

Validates against the list of keys returned by get_labels(), so any keys not returned
by get_labels will be removed and missing keys will be added and given default values.

It treats the keys "team", "played", "result" and "performances" as strings.

Strings will be filtered to replace all occurrences of ",", "<", ">", "|", and "\n"
with spaces.

Keys which are not strings will be treated as signed integers and all characters except digits
and "-" will be removed.

A key which should be an integer, but which contains nothing valid, will be set to 0.

No warnings or errors are logged.

It reurns the modified hash ref.

=cut

  sub validate_line {
    my ( $self, $line ) = validate_pos( @_, 1, { type => HASHREF } );

    my $out    = {};
    my @labels = $self->get_labels;
    foreach my $label (@labels) {
      $out->{$label} = $line->{$label};
      if ( $label =~ m/^((team)|(played)|(result)|(performances))$/x ) {
        $out->{$label} ||= "";
        $out->{$label} =~ s/[,\<\>|\n]/ /xmsg;
      }
      else {
        $out->{$label} ||= 0;
        $out->{$label} =~ s/[^\d-]//xg;
        $out->{$label} ||= 0;
      }
    }
    return $out;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

  1;
