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

our $VERSION = '0.07';

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

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2014,2015 Jeremy Mates.

This module is free software; you can redistribute it and/or modify it
under the Artistic License (2.0).

=cut
