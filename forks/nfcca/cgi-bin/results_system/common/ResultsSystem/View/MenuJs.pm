
package ResultsSystem::View::MenuJs;

use strict;
use warnings;
use CGI;
use Data::Dumper;

sub new {
  my $class=shift;
  my $self={};
  my %args=@_;

  bless $self,$class;
  $self->{logger}=$args{-logger};
  $self->set_configuration($args{-configuration}) if $args{-configuration};

  return $self;
}

=head2 menu

Returns a string containing the javascript for two arrays: menu_names and csv_files.

  if ( typeof( menu_names ) == "undefined" ) { menu_names = new Array(); }
  if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }
  
  menu_names.push( "U9N" );
  csv_files.push( "U9N.csv" );
  
  menu_names.push( "U9S" );
  csv_files.push( "U9S.csv" );

=cut

# *********************************************
sub get_menu_wrapper {

  # *********************************************
my $self = shift;

  my $js = q?
  if ( typeof( menu_names ) == "undefined" ) { menu_names = new Array(); }

  if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }

  [% MENU_LIST %]
  ?;
  return $js;
}

=head2 get_menu_lists

=cut

sub get_menu_row {
$self = shift;

return q{menu_names.push( "[% MENU_NAME %]" );
csv_files.push( "[% CSV_FILE %]" );};
}

=head2 get_all_dates_by_division_as_json

=cut

sub get_all_dates_by_division_as_json {
  my %args = (@_);

  my $dates = get_all_dates_by_division( -config => $c, -query => $q, -util => $u );

  my @lines = ();
  foreach my $div ( keys %$dates ) {
    my $line = "'" . $div . "':";

    my @weeks = map { "'" . $_ . "'" } @{ $dates->{$div} };
    my $week_line = join( ",\n", @weeks );
    $line .= '[' . $week_line . ']';

    push @lines, $line;
  }
  my $out = '{' . join( ",\n", @lines ) . '}';
  $logger->debug( Dumper $out);
  return $out;

  my $json = q?
    '[% DIV %]': { [% WEEKS %] }
  ?;
  return $json
}

=head2 get_weeks_as_json

=cut

sub get_weeks_as_json {
my $self=shift;
return q? ?;
}

=head2 main

=cut

# *********************************************
sub main {

  # *********************************************


  print $q->header( -type => "text/javascript", -expires => "+1m" );

  if ( $q->param("page") ne "week_fixtures" ) {
    menu( -config => $c, -query => $q );

    print "all_dates = \n"
      . get_all_dates_by_division_as_json( -config => $c, -query => $q ) . ";\n";
  }
  else {
    week_fixtures( -config => $c, -query => $q );
  }

}

1;
