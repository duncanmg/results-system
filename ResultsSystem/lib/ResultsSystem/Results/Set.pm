package ResultsSystem::Results::Set;

use 5.008;
use strict;
use warnings;

use Moo;
use Params::Validate qw/:all/;
use Carp;
use Data::Dumper;

=head1 NAME

ResultsSystem::Results::Set

=head1 VERSION

Version 3.01

=cut

our $VERSION = '3.01';

=head1 SYNOPSIS

An object which golds a set of Result objects.

=head1 ATTRIBUTES

=over

=item push_element

=item iterator

=item _elements

=item _create_iterator

=back

=cut

has _elements => ( 'is' => 'rw', 'default' => sub { [] } );

=head1 SUBROUTINES/METHODS

=head2 External Methods

=cut

=head3 new

my $obj = ResultsSystem::Results::Set->new()

=cut

=head3 push_element

$self->push_element( $fixture );

Add a Result object to the end of the list of Result objects or
Result::Set objects.

=cut

sub push_element {
  my ( $self, $ele ) = validate_pos( @_, 1, 1 );
  push @{ $self->_elements }, $ele;
  return 1;
}

=head3 iterator

Return an iyerator containing all the Result objects.

  my $iter = $self->iterator;
  while (my $i = $iter->()){
  	print "Got one!\n";
  }

=cut

sub iterator {
  my ($self) = validate_pos( @_, 1 );
  return $self->_create_iterator( $self->_elements );
}

=head3 count

Return the number of Result objects.

my $count = $self->count()

=cut

sub count {
  my ($self) = validate_pos( @_, 1 );
  my $eles = $self->_elements;
  return scalar @{ $self->_elements };
}

=head2 Internal Methods

=cut

=head3 _create_iterator

Helper method for creating an iterator.

=cut

sub _create_iterator {
  my ( $self, $elements ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my $i = 0;
  return sub {
    if ( $i < @$elements ) { $i++; return $elements->[ $i - 1 ]; }
    else                   { return; }
  };
}

=head3 stringify

When the object is stringified, it will take the following form:

  ResultsSystem::Results::Set with 2 elements
    week_commencing: Tuesday 1 July 2014 match_date: Wednesday 2 July 2014 home: Yorkshire0 away: Lancashire0
    week_commencing: Tuesday 1 July 2014 match_date: Wednesday 2 July 2014 home: Yorkshire1 away: Lancashire1

=cut

use overload '""' => 'stringify';

sub stringify {
  my ($self) = @_;
  my $out    = [ ref($self) . " with " . $self->count . " elements" ];
  my $iter   = $self->iterator;
  while ( my $i = $iter->() ) {
    if ( ref($i) =~ m/Result$/ ) {
      push @$out, "  " . $i . "";
    }
    else {
      # Must be a Set. Stringify, split and indent.
      my $s    = $i . "";
      my @bits = split( "\n", $i . "" );
      my $res  = join( "\n", ( map { "  " . $_ } @bits ) );
      push @$out, $res;
    }
  }
  return join( "\n", @$out );
}

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-resultssystem-fixturelist at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ResultsSystem-Results::Set>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ResultsSystem::Results::Set


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ResultsSystem-Results::Set>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ResultsSystem-Results::Set>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ResultsSystem-Results::Set>

=item * Search CPAN

L<http://search.cpan.org/dist/ResultsSystem-Results::Set/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Duncan Garland.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;

# End of ResultsSystem::Results::Set
