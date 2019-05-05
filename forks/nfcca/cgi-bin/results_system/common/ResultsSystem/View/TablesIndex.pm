  package ResultsSystem::View::TablesIndex;

=head1 NAME

ResultsSystem::View::TablesIndex

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Outputs the HTML for the table index. 

The index is an unordered list. If the table exists, then the list item contains
a link to the table. If it doesn't exist then the list item contains the name of the division
and the message "No table yet".

=cut

=head1 INHERITS FROM

L<ResultsSystem::View>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

  use strict;
  use warnings;

  use ResultsSystem::View;
  use parent qw/ResultsSystem::View/;

=head2 new

  my $v = ResultsSystem::View::TablesIndex->new( 
    {-logger => $l, -configuration => $c} );

=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;

    $self->set_arguments( [qw/logger configuration/], $args );

    return $self;
  }

=head2 run

=cut

  # *********************************************************
  sub run {

    # *********************************************************
    my ( $self, $data ) = @_;

    $data = $data->{-data};
    my $html = '';

    for my $d ( @{ $data->{divisions} } ) {
      if ( $d->{file_exists} ) {
        $html .= $self->merge_content( $self->get_item_html_file_exists, $d );
      }
      else {
        $html .= $self->merge_content( $self->get_item_html_file_not_exists, $d );
      }
    }

    $html = $self->merge_content( $self->get_html, { %$data, list_items => $html } );

    $html = $self->merge_default_stylesheet(
      $self->merge_content(
        $self->html_wrapper, { PAGETITLE => 'Results System', CONTENT => $html }
      )
    );

    $self->render( { -data => $html } );

    return 1;

  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_html

=cut

  sub get_html {
    my $self = shift;
    return <<'HTML';
<h1>[% title %]</h1>
<h2>Index of League Tables</h2>
<!-- <p><a href="[% return_to_url %]">[% return_to_title %]</a></p> -->
<ul>
[% list_items %]
</ul>

HTML
  }

=head2 get_item_html_file_exists

=cut

  sub get_item_html_file_exists {
    my $self = shift;
    return <<'HTML';
<li><a href="[% link %]">[% name %]</a></li>
HTML
  }

=head2 get_item_html_file_not_exists

=cut

  sub get_item_html_file_not_exists {
    my $self = shift;
    return <<'HTML';
<li>[% name %] - No table yet</li>
HTML
  }

  1;

