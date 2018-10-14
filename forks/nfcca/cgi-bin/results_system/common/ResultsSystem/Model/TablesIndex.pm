  package ResultsSystem::Model::TablesIndex;

=head1 NAME

ResultsSystem::Model::TablesIndex

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

  use strict;
  use warnings;
  use ResultsSystem::Model;
  use parent qw/ResultsSystem::Model/;

=head2 new

  my $index = ResultsSystem::TablesIndex->new(
    { -logger => $logger, -configuration => $configuration });

=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;

    $self->set_arguments( [qw/ configuration logger store_model/], $args );

    return $self;
  }

=head2 run

  $index->run();

Returns

  { 'title' => 'xxxxx',
    'return_to_url' => 'yyyyy',
    'divisions' => [ { 'name' => 'aaaaa', 'link' => 'bbbbb' } ]
  }

=cut

  # *********************************************************
  sub run {

    # *********************************************************
    my $self = shift;
    my $out = { divisions => [] };

    my $c     = $self->get_configuration;
    my @names = $self->_get_store_model->get_menu_names;
    $self->logger->debug( scalar(@names) . " divisions to be listed." );

    $out->{title} =
      $c->get_descriptors( -title => "Y" ) . " " . $c->get_descriptors( -season => "Y" );
    ( $out->{return_to_url}, $out->{return_to_title} ) = $c->get_return_page;

    my $d = $c->get_path( -table_dir => "Y", -allow_not_exists => 1 );

    foreach my $division (@names) {

      push @{ $out->{divisions} },
        {
        'link' => "$d/" . $self->get_html_filename( $division->{csv_file} ),
        'name' => $division->{menu_name}
        };

    }
    return $out;

  }

=head2 set_store_model

=cut

  sub set_store_model {
    my ( $self, $v ) = @_;
    $self->{store_model} = $v;
    return $self;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_html_filename

=cut

  # *********************************************************
  sub get_html_filename {

    # *********************************************************
    my ( $self, $file ) = @_;

    $file =~ s/\.csv$/\.htm/x;

    return $file;
  }

=head2 _get_store_model

=cut

  sub _get_store_model {
    my ( $self, $v ) = @_;
    return $self->{store_model};
  }

  1;

