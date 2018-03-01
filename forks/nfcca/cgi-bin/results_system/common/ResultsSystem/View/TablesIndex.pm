  package ResultsSystem::View::TablesIndex;

=head1 ResultsSystem::View::TablesIndex

=cut

  use strict;
  use warnings;

  use ResultsSystem::View;
  use parent qw/ResultsSystem::View/;

=head1 External Methods (Public)

=cut

=head2 new

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
    my $html = $self->merge_array( $self->get_item_html, $data->{divisions} );

    $html = $self->merge_content( $self->get_html, { %$data, list_items => $html } );

    $html = $self->merge_default_stylesheet(
      $self->merge_content(
        $self->html_wrapper, { PAGETITLE => 'Results System', CONTENT => $html }
      )
    );

    $self->render( { -data => $html } );

    return 1;

  }

=head1 Internal Methods (Private)

=cut

=head2 get_html

=cut

  sub get_html {
    my $self = shift;
    return q!
<h1>[% title %]</h1>
<h2>Index of League Tables</h2>
<p><a href="[% return_to_url %]">[% return_to_title %]</a></p>
<ul>
[% list_items %]
</ul>

!;
  }

=head2 get_item_html

=cut

  sub get_item_html {
    my $self = shift;
    return q!
<li><a href="[% link %]">[% name %]</a></li>
!;
  }

  1;

