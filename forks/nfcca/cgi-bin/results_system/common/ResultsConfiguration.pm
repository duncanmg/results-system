# *******************************************************
#
# Name: ResultsConfiguration.pm
#
# 0.1  - 25 Jun 08 - POD added.
# 0.2  - 20 Jul 08 - get_calculation added. 000004.
#
# *******************************************************

=head1 ResultsConfiguration.pm

=cut

=head1 Methods

=cut

{ package ResultsConfiguration;

  use XML::Simple;
  use Sort::Maker;
  use strict;
  use List::MoreUtils qw/ first_value any /;
  use Regexp::Common qw /whitespace/;
  use Data::Dumper;
  
  use Fcutils2;
  
  our @ISA;
  unshift @ISA, "Fcwrapper";

=head2 new

Constructor for the ResultsConfiguration object. Accept the full filename
of the configuration file as an argument. Does not read the file at this point.

$c = ResultsConfiguration->new( -full_filename => "/custom/config.ini" );

=cut

  #***************************************
  sub new {
  #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = ( @_ );
    my $err = 0;
    
    $self->eSet( $args{-error} ) if $args{-error};
    
    $self->set_full_filename( "../custom/results_system.ini" );
    if ( $args{-full_filename} ) {
      $err = $self->set_full_filename( $args{-full_filename} );
    }
    
    if ( $err == 0 ) {
      return $self;
    }
    else {
      $ResultsConfiguration::create_errmsg = "Could not create object. " . $self->eDump;
      return undef;
    }  
  }

=head2 _trim

Remove the leading and trailing whitespace from a string passed as as argument.

$s = $c->_trim( $s );

=cut

  #***************************************
  sub _trim {
  #***************************************
    my $self = shift; my $s = shift;
    $s =~ s/$RE{ws}{crop}//g;
    #$s =~ s/^\s*([^\s])/$1/;
    #$s =~ s/([^\s])\s*$/$1/;
    return $s;
  }

=head2 set_full_filename

Sets the full filename of the configuration file. Filters out
characters other than alphanumeric characters, "_", ".", or "/".

=cut

  #***************************************
  sub set_full_filename {
  #***************************************
    my $self = shift;
    my $err = 0;
    $self->{FULL_FILENAME} = shift;
    $self->{FULL_FILENAME} =~ s/[^\w\.\/ ]//g;
    if ( ! -f $self->{FULL_FILENAME} ) {
      $self->eAdd( $self->{FULL_FILENAME} . " does not exist.", 5 );
      $err = 1;
    }
    return $err;
  }

=head2 get_full_filename

Returns the full filename of the configuration file.

=cut

  #***************************************
  sub get_full_filename {
  #***************************************
    my $self = shift;
    return $self->{FULL_FILENAME};
  }

=head2 _get_tags

Internal method which gets the full data structure as read
from the configuration file.

=cut

  #***************************************
  sub _get_tags {
  #***************************************
    my $self = shift;
    $self->eAdd( "Warning _get_tags() returning undef.", 3 ) if ! $self->{TAGS}; 
    return $self->{TAGS};
  }

=head2 read_file

Read the configuration file. Returns an error if the file doesn't exist or the read fails.

$err = $c->read_file();

=cut

  #***************************************
  sub read_file {
  #***************************************
    my $self = shift;
    my $err = 0;
    my ( $tags );
    
    my $xml = XML::Simple->new();
    if ( ! $xml ) {
       $err = 1;
    }
        
    if ( ! -f $self->get_full_filename ) {
       $self->eAdd( "read_file(): File does not exist. " . $self->get_full_filename, 3 );
       $err = 1;
    }
    if ( $err == 0 ) { 
       eval { $tags = $xml->XMLin( $self->get_full_filename, NoAttr => 1 , ForceArray => 1, 
       SuppressEmpty => "" ); };
       if ( $@ ) { $self->eAdd($@, 5); $err=1; };
    }

    if ( $err == 0 ) {
      $self->{TAGS} = $tags;
    }

    if ( $err == 0 ) {
      $err = $self->_validate_file;
    }
    
    return $err;
  }

  #***************************************
  sub _validate_file {
  #***************************************
    my $self = shift;
    my $err = $self->_validate_paths;
    return $err;
  }
  
  #***************************************
  sub _validate_paths {
  #***************************************
    my $self = shift;
    my $err = 0;
    
    # Must be in the configuration file.
    my @mandatory_paths = ( "-htdocs", "-htdocs_full", "-table_dir_full"
                          , "-table_dir", "-results_dir_full", "-results_dir"
                          , "-cgi-dir", '-cgi-dir_full', "-htdocs", "-htdocs_full"
                          , "-csv_files", "-pwd_dir" );
                          
    # Must physically exist. ie Not paths which are relative to the document root.
    my @must_exist = ( "-htdocs_full", "-log_dir", "-table_dir_full", "-results_dir_full"
                       ,'-cgi-dir_full', "-htdocs_full", "-csv_files", "-pwd_dir" );
    
    foreach my $d ( @mandatory_paths ) {
      if ( ! $self->get_path( $d => "Y" ) ) {
        $self->eAdd( "Mandatory path $d is not in the configuration file.", 5 );
        $err = 1;
      }
    }
    
    foreach my $d ( @must_exist ) {
      my $pd = $self->get_path( $d => "Y" );
      if ( ! -d $pd ) {
        $self->eAdd( "$d should be a physical directory. $pd does not exist.", 5 );
        $err = 1;
      }
    }
    
    return $err;
  }
  
=head2 get_menu_names

Returns a list of hash references sorted by menu_position. Each hash reference has 3 mandatory elements: menu_position, menu_name and csv_file.

 @x = $c->get_menu_names();
 print $x[2]->{menu_position} . "\n";

There may also be a fourth element: no_validate_games_played

=cut

  #***************************************
  sub get_menu_names {
  #***************************************
    my $self = shift;
    my $tags = $self->_get_tags();
    my @sorted_list;
    my $div_array_ref = $tags->{divisions}[0]{division};
    if ( ! $div_array_ref ) {
      return;
    }  
    my @div_array = @$div_array_ref;
    
    # print $div_array[1]{menu_position}[0] . "\n";
    
    foreach my $d ( @div_array ) {
    
      my %h;
      map { $h{$_} = $d->{$_}[0]; $h{$_} = $self->_trim( $h{$_} ); } 
        ( "menu_position", "menu_name", "csv_file", "no_validate_games_played" );
      
      #my %h = ( menu_position => $d->{menu_position}[0],
      #          menu_name => $d->{menu_name}[0],
      #          csv_file => $d->{csv_file}[0],
      #          no_validate_games_played => $d->{no_validate_games_played[0] );
      #$h{menu_position} = $self->_trim( $h{menu_position} );
      #$h{menu_name} = $self->_trim( $h{menu_name} );
      #$h{csv_file} = $self->_trim( $h{csv_file} );
      #$h{no_validate_games_played} = $self->_trim( $h{csv_file} );
      push @sorted_list, \%h;
    }
    
    my $sorter = make_sorter( qw( ST ),
                 number => { code => '$_->{menu_position}',
                             descending => 0
                           }
                );
    @sorted_list = $sorter->( @sorted_list );
    return @sorted_list;

  }

=head2 get_name

This method returns the hash reference for the csv_file or menu_name passed as an argument.

 $h_ref = $c->get_name( -menu_name => "County 1" );
 print $h_ref->{csv_file} . "\n";
 
 $h_ref = $c->get_name( -cev_file => "CD1.csv" );
 print $h_ref->{menu_name} . "\n";

=cut

  #***************************************
  sub get_name {
  #***************************************
    my $self = shift;
    my %args = ( @_ );
    my $t;
    
    my @list = $self->get_menu_names;
    if ( $args{-menu_name} ) {
      $t = first_value { $_->{menu_name} eq $args{-menu_name} } @list;
    }
    else {
      $t = first_value { $_->{csv_file} eq $args{-csv_file} } @list;
    }
    return $t; # Hash ref
  }

=head2 _construct_path

Accepts one argument, which must be a path element. The element can
be in one of two forms:

It can be a simple string e.g. /a/b/c

or it can be a hash reference:

{ prefix => ( "path" ),
  value  => ( "/a/b/c" ) }
  
The prefix must be the name of a path which can be accessed using get_path.
This method retrieves the path and prefixes it to the contents of value.

So if "path" is /x/y/z then this method will return /x/y/z/a/b/c.

=cut

  #***************************************
  sub _construct_path {
  #***************************************
    my $self = shift; my %args = ( @_ );
    my $tags = $self->_get_tags;
    my $path;
    my $p = $args{-path};
    if ( defined( $p ) && ref( $p ) && $p->{prefix} ) {
      my $prefix = $self->get_path( '-' . $p->{prefix}[0] => 'Y' );
      my $value = $p->{value}[0];
      $path = "$prefix/$value";
    }
    else {
      $path = $p;
    }
    $path =~ s://:/:g; # Change // to /.
    return $path;
  }
  
=head2 get_path

This method accepts one named parameter and returns the appropriate path from the 
configuration file.

Valid paths are -csv_files, -log_dir, -pwd_dir, -table_dir, -htdocs,
-cgi_dir, -root. 

$path = $c->get_path( -csv_files => "Y" );

=cut

  #***************************************
  sub get_path {
  #***************************************
    my $self = shift; my %args = ( @_ );
    my $p;
    my $err = 0;
    
    $self->eAdd( "get_path() called. " . Dumper( %args ), 1 );    
    if ( scalar( @_ ) != 2 ) {
      $self->eAdd( 'Usage: $o->get_path( name_of_path => "Y" );', 5 );
      return undef;
    }

    if ( ! $self->_get_tags ) {
      $self->eAdd( "No tags are defined.", 5 );
      $err = 1;
    }
    elsif ( ! $self->_get_tags->{paths} ) {
      $self->eAdd( "No paths are defined.", 5 );
      $err = 1;
    }
    elsif ( ! %args || ! keys %args ) {
      $self->eAdd( "No path passed as an argument.", 5 );
      $err = 1;
    }
    elsif ( scalar( keys( %args ) ) != 1 ) {
      $self->eAdd( "Only one path should be requested.", 5 );
      $err = 1;
    }
    return undef if $err == 1;
 
    my @keys = keys( %args ); my $key = shift @keys;
    if ( $key !~ m/^-\w/ ) {
      $self->eAdd( "Path argument must begin with a dash followed by an alphanumeric character eg -cgi-bin", 5 );
      return undef;
    }
    
    my @valid_paths = ( "-csv_files", "-log_dir", "-pwd_dir"
                      , "-table_dir", "-results_dir", "-htdocs"
                      , '-cgi-dir', "-root", "-cgi_custom", "-season"
                      , '-htdocs_full', '-cgi-dir_full' );
                      
    $self->eAdd( "get_path() Unrecognised path: $key", 5 ) if ! any { $_ eq $key } @valid_paths;
    
    if ( $args{$key} ) {
      my $k = $key; $k =~ s/^-//;
      $p = $self->_get_tags->{paths}[0]{$k}[0];
    }
    
    $p = $self->_construct_path( -path => $p ) if $p;
    
    $p = $self->_trim( $p );
    $self->eAdd( "get_path() returning: " . $p, 1 );
    return $p;
    
  }  

=head2 get_code

This method return the password for the user passed as an argument. Returns
undefined if the user does not exist.


$pwd = $c->get_code( "fred" );

=cut

  #***************************************
  sub get_code {
  #***************************************
    my $self = shift; my $user = shift;
    my $tags = $self->_get_tags->{users} if $self->_get_tags;
    my $code;
    
    if ( ! $user ) {
      return;
    }
    
    foreach my $u ( @$tags ) {
    
      if ( $u->{user}[0] eq $user ) {
        $code = $u->{code}[0];
        last;
      }
    }
    return $self->_trim( $code );
  }  

=head2 get_season

Returns the current season.

=cut

  #***************************************
  sub get_season {
  #***************************************
    my $self = shift;
    my $s = $self->_get_tags->{descriptors}[0]{season}[0];
    return $self->_trim( $s );
  }

=head2 get_log_stem

Appends the current season to the string passed as an argument.

=cut

  #***************************************
  sub get_log_stem {
  #***************************************
    my $self = shift; my $system = shift;
    my $stem = "results_system";
    if ( $system ) {
      $stem = $system;
    }
    my $s = $self->get_season;
    if ( $s ) {
      $stem = $stem . $s;
    }
    
    return $stem;
  }  

# For testing purposes only.
sub _set_stylesheet {
  my $self = shift;
  my $h_ref = shift;
  $self->{TAGS}->{stylesheets}[0]{sheet}[0] = $h_ref->{name};
  $self->{TAGS}->{stylesheets}[0]{copy}[0] = $h_ref->{copy};
  return 0;
}

=head2 get_stylesheet

Returns a hash ref containing the name of the first stylesheet
and whether it is to be copied.

The elements of the hash ref are name and copy. The latter can
have values of "yes" and "no".

=cut

  #***************************************
  sub get_stylesheet {
  #***************************************
    my $self = shift;
    my $name = $self->_get_tags->{stylesheets}[0]{sheet}[0];
    my $copy = $self->_get_tags->{stylesheets}[0]{copy}[0];
    $name = $self->_trim( $name );
    $copy = "no" if ! $copy;
    $copy = ( $copy =~ m/yes/i ) ? "yes" : "no";
    if ( ! $name ) {
      $self->eAdd( "get_stylesheet() No sheet element found.", 3 );
      if ( $self->_get_tags->{stylesheets}[0] =~ m/\w+/ ) {
        $name = $self->_get_tags->{stylesheets}[0];
        $self->eAdd( "get_stylesheet() Return $name instead.", 3 );
      }
    }
    $self->eAdd( "get_stylesheet() returning $name.", 2 );
    return { name => $name, copy => $copy };
  }
  
=head2 get_stylesheets

Returns a list of stylesheets

=cut

  #***************************************
  # Return a list of stylesheets
  #***************************************
  sub get_stylesheets {
  #***************************************
    my $self = shift;
    my @s = @{$self->_get_tags->{stylesheets}[0]{sheet}};
    
    foreach my $sheet ( @s ) {
      $sheet = $self->_trim( $sheet );
    }
    
    return @s;
  }

=head2 get_return_page

The return link on the page will point here. Returns HTML
within a <p> tag.

=cut

  #***************************************
  # The return link on the page will point
  # here.
  #***************************************
  sub get_return_page {
  #***************************************
    my $self = shift;
    my %args = ( @_ );
    
    my $l = $self->_get_tags->{return_to}[0]{menu}[0]{href}[0];
    my $t = $self->_get_tags->{return_to}[0]{menu}[0]{title}[0];
    
    if ( $args{-results_index} ) {
      $l = $self->_get_tags->{return_to}[0]{results_index}[0]{href}[0];
      $t = $self->_get_tags->{return_to}[0]{results_index}[0]{title}[0];
    }
    
    return ( $self->_trim( $l ), $self->_trim( $t ) );
  }

=head2 get_descriptors

Returns a string. $c->get_descriptors( title => "Y" ) or
$c->get_descriptors( season => "Y" );

=cut

  #***************************************
  sub get_descriptors {
  #***************************************
    my $self = shift;
    my %args = ( @_ );
    my $d;
    
    if ( $args{-title} ) {
     $d = $self->_get_tags->{descriptors}[0]{title}[0];
    }
    elsif ( $args{-season} ) {
     $d = $self->_get_tags->{descriptors}[0]{season}[0];
    }
    elsif ( $args{-first_saturday} ) {
     $d = $self->_get_tags->{descriptors}[0]{first_saturday}[0];
     $self->eAdd( "-first_saturday sould be DD MON YYYY " . $d, 5 ) if $d !~ m/\d{1,2}[- ]\w{3}[- ]\d{4}/;
    }
    elsif ( $args{-last_saturday} ) {
     $d = $self->_get_tags->{descriptors}[0]{last_saturday}[0];
     $self->eAdd( "-last_saturday sould be DD MON YYYY " . $d, 5 ) if $d !~ m/\d{1,2}[- ]\w{3}[- ]\d{4}/;
    }
    
    return $self->_trim( $d );
  }
  
=head2 get_calculation

points or average eg $c->get_calculation( -order_by => "Y" );

=cut

  #***************************************
  sub get_calculation {
  #***************************************
    my $self = shift;
    my %args = ( @_ );
    my $v;
    if ( $args{-order_by} ) {
      $v = $self->_get_tags->{calculations}[0]{order_by}[0];
    }
    return $self->_trim( $v );
  }

=head2

Return the default debug level (debug_level) from the configuration file or
return 2 if it is not set.

=cut

  #***************************************
  sub get_default_debug_level {
  #***************************************
    my $self = shift;
    my $dbg = $self->_trim( $self->_get_tags->{debug_level}[0] );
    return ( $dbg =~ m/^\d+$/ ) ? $dbg : 2;
  }

=head2 get_points

Returns the points for "win", "draw", "tie" or "loss" from the configuration file. Defaults to 12 for a win
and 0 for a loss.

$c->get_points( "win" );

=cut

  #***************************************
  sub get_points {
  #***************************************
    my ( $self, $type ) = ( @_ );
    my %defaults = ( "win" => 12, "tie" => "", "loss" => 0, "draw" => "" );
    if ( ! defined( $defaults{$type} ) ) {
      $self->eAdd( "get_points() called with invalid type. <$type>", 5 );
      return undef;
    }
    $self->eAdd( "get_points() type=$type", 1 );
    my $points = $self->_trim( $self->_get_tags->{points}[0]{$type}[0] );
    $self->eAdd( "get_points() type=$type points=$points", 1 );
    return defined( $points ) ? $points : $defaults{$type};
  }

=head2 force_week_commencing_sunday 

The fixtures should be on the same day of the week for all weeks and all divisions. If they aren't, this option can
be used to make them appear as if they are all on Sunday.

=cut

  #***************************************
  sub force_week_commencing_sunday {
  #***************************************
    my ( $self ) = ( @_ );
    my $ret = 1;
    $self->eAdd( Dumper( $self->_get_tags ), 2 );
    $ret = undef if ! $self->_get_tags->{force_week_commencing_sunday};
    $ret = undef if ! $self->_get_tags->{force_week_commencing_sunday}[0];
    $self->eAdd( "force_week_commencing_sunday(0 returning $ret", 2 );
    return $ret;
  }

=head2 must_validate_games_played

Accepts the full csv filename of a division. Returns 1 unless the no_validate_games_played tag
evaluates to true for that division.

=cut

  #***************************************
  sub must_validate_games_played {
  #***************************************
    my ( $self, $full_filename ) = ( @_ );
    my @divisions = $self->get_menu_names();
    foreach my $d ( @divisions ) {
      if ( $d->{no_validate_games_played} && $full_filename =~ m/$d->{csv_file}$/ ) {
        $self->eAdd( "must_validate_games_played() returning 0 for $full_filename", 1 );
        return 0;
      }  
    }
    return 1;
  }
  
  1;
  
}


__END__

=head1 Example Configuration File

The configuration file is an XML file.

 <xml>

=head2 paths

 <!-- Accessed via get_path -->
 <paths>
 
 <root>
  <!-- The document root -->
  /usr/home/sehca/public_html
 </root>
 <cgi-dir>
  <!-- The location of the cgi-bin directory relative to the document root. -->
  /cgi-bin/results_system/dev
 </cgi-dir>
 <!-- The location of the csv files on the file system. Not the URL. --> 
 <csv_files>
    ../fixtures/sehca/2008
  </csv_files>
  <!-- Location of the log directory on the file system. -->
  <log_dir>
    ../../../../sehca_logs
  </log_dir>
  <!-- Directory on the file system which holds the files containing information about
  failed password entries. -->
  <pwd_dir>
    ../../../../sehca_logs
  </pwd_dir>
  <!-- Directory on the file system which contains the HTML tables. Not URL. -->
  <table_dir>
    ../../../../results_system/dev/custom/sehca/2008/tables
  </table_dir>
  <!-- location of the htdocs directory relative to the document root. -->
  <htdocs>
    /results_system/dev
  </htdocs>
  
 </paths>

=head2 descriptors

 <!-- Accessed via get_descriptors -->
 <descriptors>
  <title>
    South East Hampshire Cricket Association
  </title>
  <season>
    2008
  </season>  
 </descriptors>

=head2 return_to

  <!-- Return links --> 
  <return_to>
  <!-- The page which is to have the link. -->
  <menu>
  <!-- The URL of the link (href). -->
  <href>
    /results_system/dev/common/many_systems.htm
  </href>
  <!-- The description of the link. -->
  <title>
  Return Many Systems Page
  </title>
  </menu>
  <results_index>
  <href>
    /results_system/dev/common/many_systems.htm
  </href>
  <title>
  Return Many Systems Page
  </title>
  </results_index>
</return_to>


=head2 stylesheets

 <!-- Accessed via get_stylesheets -->
 <stylesheets>
  <sheet>
    sehca_styles.css
  </sheet>
 </stylesheets>

=head2 divisions

 <!-- See get_menu_names() and get_name() -->
 <divisions>

  <division>
  
    <menu_position>
      1
    </menu_position>
    <menu_name>
      U9
    </menu_name>
    <csv_file>
      U92008.csv
    </csv_file>
    
  </division>
  
  <division>
  
    <menu_position>
      2
    </menu_position>
    <menu_name>
      U11A
    </menu_name>  
    <csv_file>
      U11A2008.csv
    </csv_file>
    
  </division>
  
  <division>
  
    <menu_position>
      3
    </menu_position>
    <menu_name>
      U11B East
    </menu_name>  
    <csv_file>
      U11BEast2008.csv
    </csv_file>
    
  </division>
  
  <division>
  
    <menu_position>
      4
    </menu_position>
    <menu_name>
      U11B West
    </menu_name>
    <csv_file>
      U11BWest2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      5
    </menu_position>
    <menu_name>
      U13A
    </menu_name>
    <csv_file>
      U13A2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      6
    </menu_position>
    <menu_name>
      U13B East
    </menu_name>
    <csv_file>
      U11BEast2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      7
    </menu_position>
    <menu_name>
      U13B West
    </menu_name>
    <csv_file>
      U13BWest2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      8
    </menu_position>
    <menu_name>
      U15A
    </menu_name>
    <csv_file>
      U15A2008.csv
    </csv_file>
  
  </division>

  <division>
  
    <menu_position>
      9
    </menu_position>
    <menu_name>
      U15B East
    </menu_name>
    <csv_file>
      U15BEast2008.csv
    </csv_file>
  
  </division>

  <division>
  
    <menu_position>
      10
    </menu_position>
    <menu_name>
      U15B West
    </menu_name>
    <csv_file>
      U15BWest2008.csv
    </csv_file>
  
  </division>

  <division>
  
    <menu_position>
      11
    </menu_position>
    <menu_name>
      U15B Central
    </menu_name>
    <csv_file>
      U15BCentral2008.csv
    </csv_file>
  
  </division>

 </divisions>

=head2 users

 <users>
  <!-- Accessed via get_code() -->
  <user>DMG</user>
  <name>Duncan Garland</name>
  <!-- Not encrypted! -->
  <code>baffins</code>
 </users>

=head2 calculations

 <calculations>
 <order_by>
 average
 </order_by>
 </calculations>
 
 </xml>

=cut
