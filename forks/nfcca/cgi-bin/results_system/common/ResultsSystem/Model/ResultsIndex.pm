package ResultsSystem::Model::ResultsIndex;

use strict;
use warnings;
use Params::Validate qw/:all/;

=head1 NAME

ResultsSystem::Model::ResultsIndex

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

use ResultsSystem::Model;

use parent qw/ResultsSystem::Model/;

=head2 new

Constructor for the ResultIndex object.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = validate_pos( @_, 1, 1 );
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger configuration fixtures_model /], $args );

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;
  my $list = $self->_get_divisions_list;
  return $list;
}

=head2 set_fixtures_model

=cut

sub set_fixtures_model {
  my ( $self, $v ) = @_;
  $self->{fixtures_model} = $v;
  return $self;
}

=head2 get_fixtures_model

=cut

sub get_fixtures_model {
  my $self = shift;
  return $self->{fixtures_model};
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_divisions_list

This method returns all the divisions. 

=cut

# *********************************************************
sub _get_divisions_list {

  # *********************************************************
  my $self = shift;

  my $c     = $self->get_configuration;
  my @names = $c->get_menu_names;
  $self->logger->debug( scalar(@names) . " divisions to be listed." );

  my $d = $c->get_path( -csv_files_with_season => "Y" );

  my $out = [];
  foreach my $division (@names) {

    my $dates = $self->_get_division_date_list( $d, $division->{csv_file} );
    push @$out,
      {
      division  => $division->{csv_file},
      menu_name => $division->{menu_name},
      'dates'   => $dates
      };

  }

  return $out;

}

=head2 _get_division_date_list

=cut

# *********************************************************
sub _get_division_date_list {

  # *********************************************************
  my ( $self, $dir, $file ) = validate_pos( @_, 1, 1, 1 );

  my $res_file;

  my $fixtures = $self->get_fixtures_model;
  eval {
    $fixtures->set_full_filename("$dir/$file");
    $fixtures->read_file;
    1;
  } || do {
    my $err = $@;
    $self->logger->warn($err);
    return [];
  };

  my $dates = $fixtures->get_date_list;

  my $out = [];
  foreach my $d (@$dates) {

    $res_file = $self->_build_filename( $file, $d );

    push @$out, { 'matchdate' => $d, 'url' => $res_file };
  }

  $self->logger->debug( "$dir/$file contains " . scalar(@$out) . " dates." );

  return $out;

}

=head2 _build_filename

=cut

sub _build_filename {
  my ( $self, $division, $week ) = validate_pos( @_, 1, { type => SCALAR }, { type => SCALAR } );

  my $c = $self->get_configuration;
  my $dir = $c->get_path( -results_dir => "Y", -allow_not_exists => 'Y' );

  my $f = $division;    # The csv file
  my $w = $week;        # The csv file
  $f =~ s/\..*$//x;     # Remove extension
  $f = "$dir/${f}_$w.htm";    # Add the path

  return $f;
}

1;

