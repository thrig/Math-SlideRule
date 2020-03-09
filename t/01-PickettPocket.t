#!perl
#
# NOTE these tests must be guarded with sprintf (quick n' easy) or
# floating point math rounding errors properly accounted for (harder)

use strict;
use warnings;

use Test::Most;    # plan is down at bottom

BEGIN {
    use_ok('Math::SlideRule::PickettPocket') || print "Bail out!\n";
}
diag(
    "Testing Math::SlideRule::PickettPocket $Math::SlideRule::PickettPocket::VERSION, Perl $], $^X"
);

my $sr = Math::SlideRule::PickettPocket->new;
isa_ok($sr, 'Math::SlideRule::PickettPocket');

########################################################################
#
# Public methods

is(sprintf("%.3f", $sr->divide(75, 92)), 0.815, 'simple divide');
# hmm, frequent rounding to tickmarks gets different result than what
# one can do by matching up the hairline (which suggested something
# closer to 5.1 for me, on a second take I'd pick 5.075 as the hairline
# is in the middle of the upper half of the 5.0 to 5.1 space). that is,
# in a chain operation, can skip the round-to-nearest that this code
# does at each step. this might compound accuracy or error depending on
# how well the rule is used?
is(sprintf("%.4f", $sr->divide(14, 92, 3)), 0.0505, 'less simple divide');

is(sprintf("%.2f", $sr->multiply(1.1, 2.2)), 2.42, 'simple multiply');
is(sprintf("%.1f", $sr->multiply(4.1, 3.7)), 15.2, 'magnitude shift result');
is(sprintf("%.1f", $sr->multiply(99,   99)),   '9800.0', 'big multiply');
is(sprintf("%.4f", $sr->multiply(0.02, 0.02)), 0.0004,   'small multiply');

# I try not to be negative, but these things happen.
is(sprintf("%.2f", $sr->multiply(1.1,  -2.2)), -2.42, 'negative');
is(sprintf("%.2f", $sr->multiply(-1.1, -2.2)), 2.42,  'not negative');

is(sprintf("%.1f", $sr->multiply(42, 31, 28, 215)),
    '7850000.0', 'chain multiply');
is(sprintf("%.1f", $sr->multiply(42, -31, -28, -215)),
    '-7850000.0', 'chain multiply neg');

plan tests => 12;
