# -*- Perl -*-
#
# Slide rule support for Perl. Mostly as Perl and slide rule practice for the
# author, but might be handy to simulate values someone using a slide rule
# might come up with? I dunno.
#
# *** BETA interface, may change ***

package Math::SlideRule;

use 5.010000;
use strict;
use warnings;

use Carp qw/confess croak/;
use Moo;
use namespace::clean;
use Scalar::Util qw/looks_like_number/;

our $VERSION = '0.04';

########################################################################
#
# ATTRIBUTES

has C => (
  clearer => 1,
  coerce  => sub { __PACKAGE__->round( $_[0] ) },
  is      => 'rw',
);

has D => (
  clearer => 1,
  coerce  => sub { __PACKAGE__->round( $_[0] ) },
  is      => 'rw',
);

########################################################################
#
# METHODS

# Cannot just pass m*(1/n) to multiply() because that looses precision: .82 for
# 75/92 while can get .815 on pocket slide rule. On a slide rule, this is just
# multiplication done backwards.
#
# TODO support chain division, would that be ((n/m)/o)/p form ?
sub divide {
  my $self = shift;
  my ( $n, $m ) = @_;
  croak "need two numbers"
    if !looks_like_number($n)
    or !looks_like_number($m)
    or @_ > 2;

  my $is_negative = ( ( $n < 0 and $m >= 0 ) or ( $n >= 0 and $m < 0 ) );
  ( $n, my $n_exp ) = $self->standard_form($n);
  ( $m, my $m_exp ) = $self->standard_form($m);

  my $val = $self->C($n) / $self->D($m);

  if ( $val < 1 ) {
    $val *= 10;
    $n_exp--;
  }
  $val = $self->round($val) * 10**( $n_exp - $m_exp );

  $val *= -1 if $is_negative;
  return $val;
}

sub multiply {
  my $self = shift;
  my $n    = shift;
  croak "need at least two numbers" if @_ < 1;

  my $i = 0;
  croak "argument index $i not a number" if !looks_like_number($n);

  my $neg_count = $n < 0 ? 1 : 0;
  my ( $n_coe, $n_exp ) = $self->standard_form($n);

  # Chain method has first lookup on D and then subsequent done by moving C on
  # slider and keeping tabs with the hairline, then reading back on D for the
  # final result. (Plus incrementing the exponent count when a reverse slide is
  # necessary, for example for 3.4*4.1, as that jumps to the next magnitude.)
  my $product  = $self->D($n_coe);
  my $exponent = $n_exp;

  for my $m (@_) {
    $i++;
    croak "argument index $i not a number" if !looks_like_number($m);

    $neg_count++ if $m < 0;
    my ( $m_coe, $m_exp ) = $self->standard_form($m);

    $product *= $self->C($m_coe);
    $exponent += $m_exp;

    # order of magnitude change, adjust back to bounds (these notable on slide
    # rule by having to index from the opposite direction than usual).
    if ( $product > 10 ) {
      $product /= 10;
      $exponent++;
    }
    $product = $self->round($product);
  }

  $product *= 10**$exponent;
  $product *= -1 if $neg_count % 2 == 1;

  return $product;
}

sub round {
  my $self = shift;
  confess "uh oh" if !defined $_[0];
  die "input value '$_[0]' must be number 1 <= n <= 10"
    if !looks_like_number( $_[0] )
    or $_[0] < 1,
    or $_[0] > 10;
  sprintf "%0.2f", $_[0];
}

# Converts numbers to standard form (scientific notation) as slide rule can
# only deal with numbers 1..10; exponent and sign must be handled elsewhere.
sub standard_form {
  my $self = shift;

  my $val = abs(shift);
  my $exp = 0;
  if ( $val < 1 ) {
    # TODO better way? how does sprintf "%e" figure out the sci notation?
    while ( $val < 1 ) {
      $val *= 10;
      $exp--;
    }
  } elsif ( $val > 10 ) {
    while ( $val > 10 ) {
      $val /= 10;
      $exp++;
    }
  }
  return $val, $exp;
}

1;
__END__

=head1 NAME

Math::SlideRule - slide rule support for Perl

=head1 SYNOPSIS

Simulate an analog computer.

*** BETA interface, may change without warning ***

    use Math::SlideRule;

    my $sr = Math::SlideRule->new();

    # set where the slide rule is (these don't do much, and are at
    # present not linked as things on the slider bit would be)
    $sr->C(1.5);
    $sr->D(3.7);

    $sr->round(1.234); # 1.23 via sprintf()

    # scientific notation breakdown
    $sr->standard_form(1234); # [ 1.234, 3 ]

    # these set ->C, ->D, handle the tricky decimals, etc.
    $sr->divide(75, 92);
    $sr->multiply(1.5, 3.7);
    $sr->multiply(-1.1, 2.2, -3.3, 4.4);

=head1 DESCRIPTION

Slide rule support for Perl. The abbreviated slide rule names (short letter
names like C, D, etc.) are retained as attributes (though do not do much).
Rounding is performed on the input and output values.

Certain slide rule realities are skipped, such as left versus right sliding
based on whether the result stays within the same order of magnitude: C<1.1 *
2.5> and C<4.1 * 3.7> require opposite sliding directions to compute, and one
requires more management of the decimal.

L<Math::SlideRule::PickettPocket> approximates a N 3P-ES pocket slide rule.

=head1 ATTRIBUTES

Calls will C<croak> or C<die> if something goes awry.

C<C>, C<D>, and C<clear_*> to hold values for particular slide rule lookups, or
to clear such. Largely irrelevant? (Used by C<multiply> and other methods.)

=head1 METHODS

C<round> rounds the input number via C<sprintf>. It should be overridden in any
subclasses to suit the particulars of the slide rule being implemented.
Otherwise is mostly used internally.

C<standard_form> returns a number as a list consisting of the characteristic
and exponent of that number. Mostly used internally by various other routines.

C<multiply> requires two (or more) numbers, multiples them, returns result.
There's a C<divide> as well, though that only takes two numbers. (There is no
support for the combined multiplication and division tricks possible on a
slide rule.)

=head1 BUGS

=head2 Reporting Bugs

If the bug is in the latest version, send a report to the author.
Patches that fix problems or add new features are welcome.

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-SlideRule>

L<http://github.com/thrig/Math-SlideRule>

=head2 Known Issues

No known issues. Probably lots. (But hardly anything is implemented, so that's
probably a big issue.)

=head1 AUTHOR

Jeremy Mates, C<< <jmates at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Jeremy Mates.

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
