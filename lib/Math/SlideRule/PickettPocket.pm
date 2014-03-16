# -*- Perl -*-
#
# Slide rule support for Perl, specific to my Pickett Model N 3P-ES pocket
# slide rule, insofar as that is possible on a digital device.

package Math::SlideRule::PickettPocket;

use 5.010000;

use Moo;
use namespace::clean;
use Scalar::Util qw/looks_like_number/;

extends 'Math::SlideRule';

our $VERSION = '0.05';

# Fairly accurate, though humans might (try to) do better in some cases by
# trying to guess where 9.99 is, so in theory "close but random" code might
# better reproduce what a slide rule can do. This is based off of the C/D
# scales; A/B rounding would be worse, as those scales cover two orders of
# magnitude in the same distance.
sub round {
  my $self = shift;

  # Check input only here as with 'isa' on the attributes would need to make
  # the is-number check both here and over in the isa.
  die "input value '$_[0]' must be number 1 <= n <= 10"
    if !looks_like_number( $_[0] )
    or $_[0] < 1,
    or $_[0] > 10;

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

1;
__END__

=head1 NAME

Math::SlideRule::PickettPocket - N 3P-ES pocket slide rule

=head1 SYNOPSIS

Approximate a N 3P-ES pocket slide rule.

    use Math::SlideRule::PickettPocket;
    my $sr = Math::SlideRule::PickettPocket->new();

    $sr->divide(75, 92);
    $sr->multiply(-1.1, 2.2, -3.3, 4.4);
    ... (and etc. see Math::SlideRule)

=head1 DESCRIPTION

A Pickett Model N 3P-ES pocket slide rule implementation, primarily in the
custom L<round()> method that approximates with C<sprintf()> what a human can
do, in particular higher resolutions for lower numbers. Only "halfway between"
the tick marks is supported; a human might do better with making 9.99 line up a
skosh off the 10 tick.

Otherwise, consult L<Math::SlideRule> for the available attributes and methods
and so forth.

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
