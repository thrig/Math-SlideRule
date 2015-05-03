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

our $VERSION = '1.00';

# TODO custom A/C attribute with lookup tables suitable to tickmarks extant

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
