# -*- Perl -*-
#
# Slide rule support for Perl. Mostly as Perl and slide rule practice for the
# author, but might be handy to simulate values someone using a slide rule
# would come up with? I dunno.
#
# *** BETA interface, may change ***

package Math::SlideRule;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use Scalar::Util qw/looks_like_number/;

use Moo;
use namespace::clean;

our $VERSION = '0.02';

########################################################################
#
# SKETCHY INTERNAL JUNK DO NOT USE LOOK I WARNED YOU

# Bounds check for numeric input (limits might come from ->new if there be
# slide rules that have larger ranges, but I suspect they might instead try to
# pack in more resolution over the 1..10 space). In particular, some of the
# logic below conflates these with order-of-magnitude changes.
my $SR_MIN = 1;
my $SR_MAX = 10;

# Makes a number positive and within the ruler bounds, returns normalized
# number and the exponent of the offset the original was from the bounds.
# (I hope you're handling the negatives somewhere else!)
sub _normalize {
  my $val = abs(shift);
  my $exp = 0;
  if ( $val < $SR_MIN ) {
    # TODO better way? how does sprintf "%e" figure out the sci notation?
    while ( $val < $SR_MIN ) {
      $val *= 10;
      $exp--;
    }
  } elsif ( $val > $SR_MAX ) {
    while ( $val > $SR_MAX ) {
      $val /= 10;
      $exp++;
    }
  }
  return $val, $exp;
}

# TODO these resolutions are specific to my pocket slide rule, so really
# should not be in the main module. Additional work might be to randomize
# things "a little" for when the human is guessing between the lines, but
# that's more work.
sub _round {
  # check input only here as with isa would need to make is-number check both
  # here and over in the isa.
  die "input value must be number $SR_MIN <= n <= $SR_MAX"
    if !looks_like_number( $_[0] )
    or $_[0] < $SR_MIN,
    or $_[0] > $SR_MAX;

  if ( $_[0] < 3 ) {
    # e.g. 1.01 at best, though marks only at .02, .04, .06, ...
    return sprintf "%.2f", $_[0];
  }

  if ( $_[0] < 5 ) {
    # e.g. 4.025 at best, marks at .05, .10, .15, ...
    # maths (now better) lifted from Math::Round::Var
    return sprintf( "%0.0f", $_[0] / 0.025 ) * 0.025;
  }

  # e.g. 9.05 at best, marks at .10, .20, .30, ...
  return sprintf( "%0.0f", $_[0] / 0.05 ) * 0.05;
}

########################################################################
#
# ATTRIBUTES

has C => (
  clearer => 1,
  coerce  => \&_round,
  is      => 'rw',
);

has D => (
  clearer => 1,
  coerce  => \&_round,
  is      => 'rw',
);

########################################################################
#
# METHODS

sub multiply {
  my $self = shift;
  my ( $n1, $n2 ) = @_;
  croak "need two numbers"
    if !looks_like_number($n1)
    or !looks_like_number($n2);

  my $is_negative = ( ( $n1 < 0 and $n2 >= 0 ) or ( $n1 >= 0 and $n2 < 0 ) );
  ( $n1, my $n1_exp ) = _normalize($n1);
  ( $n2, my $n2_exp ) = _normalize($n2);

  # cheat and just multiply (these attributes round the values)
  my $val = $self->C($n1) * $self->D($n2);

  # order of magnitude change, adjust back to bounds
  if ( $val > $SR_MAX ) {
    $val /= 10;
    $n1_exp++;
  }
  # read off value from slide (must be rounded) and figure out where the
  # decimal goes
  $val = _round($val) * 10**( $n1_exp + $n2_exp );

  $val *= -1 if $is_negative;
  return $val;
}

1;
__END__

=head1 NAME

Math::SlideRule - slide rule support for Perl

=head1 SYNOPSIS

*** BETA interface, may change without warning ***

    use Math::SlideRule;

    my $sr = Math::SlideRule->new();

    # set where the slide rule is (these don't do much)
    $sr->C(1.5);
    $sr->D(3.7);

    # sets ->C, ->D, multiplies, handles tricky decimals, etc.
    $sr->multiply(1.5, 3.7);

=head1 DESCRIPTION

Slide rule support for Perl, based in particular on the capabilities of my
Pickett Model N 3P-ES pocket slide rule. As such, the abbreviated rule names
(short letter names) are retained for the values that can be set to on the
software slide rule. Numeric values are rounded as necessary, though this
should really only be done in a subclass specific to a particular length of
slide rule (patches welcome for 10" or 20" slide rule number resolutions).

Certain slide rule realities are skipped, such as left versus right sliding
based on whether the result stays within the same order of magnitude: C<1.1 *
2.5> and C<4.1 * 3.7> require opposite sliding directions to compute, and the
decimal must be managed for one.

=head1 ATTRIBUTES

C<C>, C<D>, and C<clear_*> to hold values for particular slide rule lookups, or
to clear such. Largely irrelevant?

=head1 METHODS

C<multiply> requires two numbers, multipies them, returns result.

=head1 BUGS

=head2 Reporting Bugs

If the bug is in the latest version, send a report to the author.
Patches that fix problems or add new features are welcome.

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-SlideRule>

L<http://github.com/thrig/Math-SlideRule>

=head2 Known Issues

No known issues. (But hardly anything is implemented, so that's probably a
big issue.)

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
