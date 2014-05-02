# -*- Perl -*-
#
# Slide rule support for Perl. Mostly as Perl (Moo) and slide rule practice for
# the author, but might be handy to simulate values someone using a slide rule
# might come up with? I dunno.
#
# *** BETA interface, may change ***

package Math::SlideRule;

use 5.010000;

use Carp qw/confess croak/;
use Moo;
use namespace::clean;
use Scalar::Util qw/looks_like_number/;

our $VERSION = '0.06';

########################################################################
#
# ATTRIBUTES
#
# There used to be C/D 'has' for the value those might be set to on the
# rule, though if one adds the full set from just my rule--square root even
# digits, square root odd digits, K, A, B, ST, S, T (twice), CI, C, D, DI,
# three more for doing cube roots, plus 11 mostly log related scales on the
# flip side--updating all of these as appropriate when any one attribute
# changes: yeah, no. So the C/D were removed.

########################################################################
#
# METHODS

# Division is just multiplication done backwards on a slide rule, as the same
# physical distances are involved. There are also "CF" and "CI" (C scale,
# folded, or inverse) and so forth scales to assist with such operations,
# though these help avoid excess motions on the slide rule.
#
# NOTE cannot just pass m*(1/n) to multiply() because that looses precision:
# .82 for 75/92 while can get .815 on pocket slide rule.
sub divide {
  my $self = shift;
  my $n    = shift;
  croak "need at least two numbers" if @_ < 1;

  my $i = 0;
  croak "argument index $i not a number" if !looks_like_number($n);

  my $neg_count = $n < 0 ? 1 : 0;

  my ( $n_coe, $n_exp ) = $self->standard_form($n);
  my $product  = $self->round($n_coe);
  my $exponent = $n_exp;

  for my $m (@_) {
    $i++;
    croak "argument index $i not a number" if !looks_like_number($m);

    $neg_count++ if $m < 0;
    my ( $m_coe, $m_exp ) = $self->standard_form($m);

    $product /= $self->round($m_coe);
    $exponent -= $m_exp;

    if ( $product < 1 ) {
      $product *= 10;
      $exponent--;
    }
    $product = $self->round($product);
  }

  $product *= 10**$exponent;
  $product *= -1 if $neg_count % 2 == 1;

  return $product;
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
  #
  # One can also do the multiplication on the A and B scales, which is handy if
  # you then need to pull the square root off of D. But this implementation
  # ignores such alternatives.
  my $product  = $self->round($n_coe);
  my $exponent = $n_exp;

  for my $m (@_) {
    $i++;
    croak "argument index $i not a number" if !looks_like_number($m);

    $neg_count++ if $m < 0;
    my ( $m_coe, $m_exp ) = $self->standard_form($m);

    $product *= $self->round($m_coe);
    $exponent += $m_exp;

    # Order of magnitude change, adjust back to bounds (these notable on slide
    # rule by having to index from the opposite direction than usual for the C
    # and D scales (though one could also obtain the value with the A and B or
    # the CI and DI scales, but those would then need some rule to track the
    # exponent change)).
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

# Generic rounding; a real slide rule has different resolutions possible for
# different scales (C/D vs. A/B) and also within those scales. See
# PickettPocket.pm for an attempt at C/D, though humans can often fudge out
# better numbers by reading between the lines (they can also make incorrect or
# totally wrong fudges, so...).
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

Simulate an analog computer (without much nuance).

*** BETA interface, may change without warning ***

    use Math::SlideRule;

    my $sr = Math::SlideRule->new();

    $sr->round(1.234); # 1.23 via sprintf()

    # scientific notation breakdown
    $sr->standard_form(1234); # [ 1.234, 3 ]

    $sr->divide(75, 92);
    $sr->multiply(1.5, 3.7);
    $sr->multiply(-1.1, 2.2, -3.3, 4.4);

=head1 DESCRIPTION

Slide rule support for Perl. More rounding than perhaps is necessary is the
main feature of this module. L<Math::SlideRule::PickettPocket> approximates a N
3P-ES pocket slide rule.

=head1 METHODS

Calls will C<croak> or C<die> if something goes awry.

C<round> rounds the input number via C<sprintf>. It should be overridden in any
subclasses to suit the particulars of the slide rule being implemented.
Otherwise is mostly used internally.

C<standard_form> returns a number as a list consisting of the characteristic
and exponent of that number. Mostly used internally by various other routines.

C<multiply> requires two (or more) numbers, multiples them, returns result.
There's a C<divide> as well. (There is no support for the combined
multiplication and division tricks possible on a slide rule.)

=head1 BUGS

=head2 Reporting Bugs

If the bug is in the latest version, send a report to the author.
Patches that fix problems or add new features are welcome.

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-SlideRule>

L<http://github.com/thrig/Math-SlideRule>

=head2 Known Issues

C<round> will need to be modified to specify what sort of rounding need be
done, as the various scales have various resolutions possible (and may vary by
the number under consideration, as square roots divide the scale into two, and
cube roots that same space into three).

A more realistic implementation might use XS, and C<malloc> a large amount of
contiguous memory, and then "slide" pointers around therein to represent where
the slider and hairline are. The scales would be mapped into this region of
memory, so that address C<0x0> would be C<1> of the D scale, and the highest
memory address 10 of that scale, and the other values laid out as appropriate
between those posts. With a large amount of memory, suitable resolution might
be gained, though rounding would be necessary for the many results that would
fall into memory addresses not associated with some tick mark of the scale in
question. (That the slider needs be movable and therefore the mapping of any
scales on it might be tricky?)

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
