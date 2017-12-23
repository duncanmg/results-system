# ************************************************************
#
# Name: FileRenderer.pm
#
#
# ************************************************************

=head1 FileRenderer.pm

This package provides the methods which several objects in the results system inherit.

It inherits from Parent and add three more methods which handle stylesheets.

They are all marked with an underscore which means they can be inherited, but do not
form part of the API of the child class.

In fact only _copy_stylesheet and _get_sheet are used by the child classes.

TODO Don't understand what this does or why it is necessary.

=cut

=head1 Methods

=cut

{

  package FileRenderer;

  use strict;
  use warnings;

  use File::Basename;
  use File::stat;
  use File::Copy;

  use Parent;

  our @ISA = qw/Parent/;

=head2 Methods used by child classes

=cut

=head3 _copy_stylesheet

  $self->_copy_stylesheet($type);

This doesn't do anything unless the "copy" element of the stylesheet
info in the configuration is set it "yes".

If it is "yes" ...

=cut

  #***************************************
  sub _copy_stylesheet {

    #***************************************
    my $self       = shift;
    my $type       = shift;
    my $err        = 0;
    my $c          = $self->get_configuration;
    my $sheet_info = $self->_get_default_sheet;
    if ( $sheet_info->{copy} eq "yes" ) {
      my $s = "../../htdocs/custom/" . $sheet_info->{name};
      if ( !-f $s ) {
        $self->logger->error("$s does not exist.");
        return 1;
      }

      my $ls = $self->_get_sheet( $type, "physical" );
      return 1 if !$ls;

      copy( $s, $ls ) if !$ls;
      my $s_stats  = stat($s);
      my $ls_stats = stat($ls);
      if ( !-f $ls || $s_stats->mtime > $ls_stats->mtime ) {
        my $ok = copy( $s, $ls );
        if ( !$ok ) {
          $self->logger->error( "Unable to copy $s to $ls. " . $! );
          return 1;
        }
      }
    }
    return $err;
  }

=head3 _get_sheet

  $self->_get_sheet( $type, $location );

$type - Can be "table_dir" or "results_dir"

$location - Can be "physical" or "web"

Behaves differently if the copy element of the sheet is "yes" or "no".

Seems to be called with "physical" if the stylesheet is to be copied
and "web" from elsewhere.

=cut

  #***************************************
  sub _get_sheet {

    #***************************************
    my $self     = shift;
    my $type     = shift;    # table_dir or results_dir
    my $location = shift;    # physical or web
    my $path;
    my ( $t_dir_physical, $r_dir_physical, $htdocs, $season, $t_dir_web, $r_dir_web );

    if ( !defined $type || !defined $location ) {
      $self->logger->error(
        "_get_sheet( type, location ) Undefined parameter <$type> <$location>");
      return undef;
    }

    my $c     = $self->get_configuration;
    my $sheet = $self->_get_default_sheet->{name};
    my $copy  = $self->_get_default_sheet->{copy};

    $sheet = fileparse $sheet;

    if ( $copy eq "yes" ) {
      $t_dir_physical = $c->get_path( -table_dir_full   => "Y" );
      $r_dir_physical = $c->get_path( -results_dir_full => "Y" );
      $htdocs         = $c->get_path( -htdocs           => "Y" );
      $season         = $c->get_season;
      $t_dir_web      = "";
      $r_dir_web      = "";
    }
    else {
      $htdocs = $c->get_path( -htdocs => "Y", -allow_not_exists => 1 );
      my $htdocs_full = $c->get_path( -htdocs_full => "Y" );
      $season = $c->get_season;
      my $system = $c->get_path( -system => "Y", -allow_not_exists => 1 );
      $t_dir_physical = "$htdocs_full/custom/$system";
      $r_dir_physical = "$htdocs_full/custom/$system";
      $t_dir_web      = "$htdocs/custom/$system";
      $r_dir_web      = "$htdocs/custom/$system";
    }

    if ( $type eq "table_dir" ) {
      my $s = $location eq "physical" ? $t_dir_physical : $t_dir_web;
      return $s ? "$s/$sheet" : $sheet;
    }
    else {
      my $s = $location eq "physical" ? $r_dir_physical : $r_dir_web;
      return $s ? "$s/$sheet" : $sheet;
    }
    return undef;
  }

=head2 Methods not used elsewhere

=cut

=head3 _get_default_sheet

This calls get_stylesheet(0 on the configuration object
and returns the result.

=cut

  #***************************************
  sub _get_default_sheet {

    #***************************************
    my $self = shift;

    my $c     = $self->get_configuration;
    my $sheet = $c->get_stylesheet;

    return $sheet;
  }

  1;

}
