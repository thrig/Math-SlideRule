# -*- Perl -*-
#
# Slide rule support for Perl. *** BETA interface, may change ***

package Math::SlideRule;

use 5.010000;
use strict;
use warnings;

# TODO
#use Carp qw/croak/;
use Scalar::Util qw/looks_like_number/;

use Moo;
use namespace::clean;

our $VERSION = '0.01';

# TODO these resolutions specific to my pocket slide rule, should not be in
# main module (maths lifted from Math::Round::Var)
sub _round {
  if ( $_[0] < 3 ) {
    # 1.01 at best, though only marks at the 1.0[2468] points
    return sprintf "%.2f", $_[0];
  }

  if ( $_[0] < 5 ) {
    # 4.025 at best, marks at .05, .10, .15, ...
    return sprintf( "%.2f", $_[0] / 0.025 ) * 0.025;
  }

  # 9.05 at best, marks at .1, .2, .3, ...
  return sprintf( "%.2f", $_[0] / 0.05 ) * 0.05;
}

has C => (
  clearer => 1,
  coerce  => \&_round,
  is      => 'rw',
  isa     => sub {
    die "input value must be number >=1 and <=10\n"
      if !looks_like_number( $_[0] )
      or $_[0] < 1
      or $_[0] > 10;
  },
);

has D => (
  clearer => 1,
  coerce  => \&_round,
  is      => 'rw',
  isa     => sub {
    die "input values must be numbers >=1 and <=10"
      if !looks_like_number( $_[0] )
      or $_[0] < 1
      or $_[0] > 10;
  },
);

# TODO awkward method name (or write multiply() that keeps track of digits,
# sets C, D, etc.
sub look_C_D {
  my $self = shift;

  die "C not set\n" unless $self->C;
  die "D not set\n" unless $self->D;

  return $self->C * $self->D;
}

1;
__END__

=head1 NAME

Math::SlideRule - slide rule support for Perl

=head1 SYNOPSIS

*** BETA interface, may change without warning ***

    use Math::SlideRule;

    my $sr = Math::SlideRule->new();

    # multiply 15 by 3.7
    $sr->C(1.5);      # whoops, must shift 15 to be 1 <= n <= 10
    $sr->D(3.7);
    $sr->look_C_D();  # 5.55 (really 55.5 but thems the breaks)

=head1 DESCRIPTION

Slide rule support for Perl, based in particular on the capabilities of a
Pickett Model N 3P-ES pocket slide rule. As such, the abbreviated rule names
(short letter names) are retained for the values those can be set to on the
slide rule. Numeric values are rounded, though this should really only be done
in subclasses specific to a particular length of slide rule.

TODO left-index vs. right-index lookups, or would that be too annoying?

=head1 METHODS

C, D, look_C_D, and clear_{C,D} with presumably more to come.

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
