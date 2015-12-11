package FormValidator;

use 5.008;
use Moose;
use Data::FormValidator;
use Data::FormValidator::Constraints qw/:closures/;
use Params::Validate qw/:all/;
use Carp::Assert;

use FormValidator::Constraints qw/:all/;

my $pairs = {
    FV_length_between     => \&FV_length_between,
    FV_max_length         => \&FV_max_length,
    FV_min_length         => \&FV_min_length,
    FV_eq_with            => \&FV_eq_with,
    FV_num_values         => \&FV_num_values,
    FV_num_values_between => \&FV_num_values_between,
    email                 => \&email,
    state_or_province     => \&state_or_province,
    state                 => \&state,
    province              => \&province,
    zip_or_postcode       => \&zip_or_postcode,
    postcode              => \&postcode,
    zip                   => \&zip,
    phone                 => \&phone,
    american_phone        => \&american_phone,
    cc_number             => \&cc_number,
    cc_exp                => \&cc_exp,
    cc_type               => \&cc_type,
    ip_address            => \&ip_address,

    match_pos_integer     => \&match_pos_integer
};

=head1 NAME

FormValidator - The great new FormValidator!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FormValidator;

    my $foo = FormValidator->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 Attributes

=cut

has _validator => (
    'is'      => 'ro',
    => 'isa'  => 'Object',
    'default' => sub {
        Data::FormValidator->new( {},
            { validator_packages => 'FormValidator::Constraints' } );
    }
);

=head2 Methods

=cut

=head3 External Methods

=cut

=head4 check

=cut

sub check {
    my ( $self, $input, $profile ) = @_;

    $profile->{constraint_methods} =
      $self->substitute_constraints( $profile->{constraint_methods} );

    $self->_validator->check( $input, $profile );
}

=head3 Internal Methods

=cut

=head4 substitute_constraints

$self->substitute_constraints( $constraints );

Receives the "constraint_methods" key of the profile. This
will be a hash ref in which each key is a field and each
value a constraint or an array ref of constraints.

Passes the constraints for each field in turn to substitute_constraints.

=cut

sub substitute_constraints {
    my ( $self, $constraints ) =
      validate_pos( @_, 1, { type => HASHREF | UNDEF, optional => 1 } );
    return $constraints if !$constraints;

    for my $k ( keys %$constraints ) {
        my $v = $constraints->{$k};
        my $list = ( ref($v) eq 'ARRAY' ) ? $v : [$v];
        $constraints->{$k} = $self->substitute($list);
    }
    return $constraints;
}

=head4 substitute

Accepts a single constraint or a list of constraints.

$self->substitute( [ "email" ] );

$self->substitute( [ "email", [ "FV_max_length", 10 ] ] );

$self->substitute( [ "email", [ "FV_max_length", 10 ], qr/x/ix ] );

$self->substitute( [ "email", [ "FV_max_length", 10 ], sub { $_[1] ? 1 : 0 } ] );

$self->substitute( [ "FV_max_length", 10 ] );

=cut

sub substitute {
    my ( $self, $constraints ) = validate_pos( @_, 1, { type => ARRAYREF } );

    my $out = [];

    my $process_builtin = sub {
        my $c = shift;
        my $f = shift @$c;
        assert( $pairs->{$f}, "$f is a builtin" );
        push @$out, $pairs->{$f}->(@$c);
    };

    if ( $pairs->{ $constraints->[0] } ) {
        $process_builtin->($constraints);
        return $out;

    }

    for my $c (@$constraints) {

        my $ref = ref($c);

        if ( $ref && ( $ref ne 'ARRAY' ) ) {
            push @$out, $c;
            next;
        }

        if ($ref) {

            # Array ref, so the first element is the name.
            $process_builtin->($c);
        }
        else {
            # Single value eg "email".
            push @$out, $pairs->{$c}->() if $pairs->{$c};
        }

    }

    return $out;
}

=head1 AUTHOR

Duncan Garland, C<< <duncan.garland at ntlworld.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-formvalidator at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FormValidator>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FormValidator


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=FormValidator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/FormValidator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/FormValidator>

=item * Search CPAN

L<http://search.cpan.org/dist/FormValidator/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Duncan Garland.

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

1;    # End of FormValidator
