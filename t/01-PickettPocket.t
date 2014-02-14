#!perl

use strict;
use warnings FATAL => 'all';

use Test::More;    # plan is down at bottom
use Test::Exception;

BEGIN {
  use_ok('Math::SlideRule::PickettPocket') || print "Bail out!\n";
}
diag(
  "Testing Math::SlideRule::PickettPocket $Math::SlideRule::PickettPocket::VERSION, Perl $], $^X"
);

my $sr = Math::SlideRule::PickettPocket->new;
isa_ok( $sr, 'Math::SlideRule::PickettPocket' );

########################################################################
#
# Public methods

is( $sr->divide( 75, 92 ), 0.815, 'simple divide' );

is( $sr->multiply( 1.1,  2.2 ),  2.42,   'simple multiply' );
is( $sr->multiply( 4.1,  3.7 ),  15.2,   'magnitude shift result' );
is( $sr->multiply( 99,   99 ),   9800,   'big multiply' );
is( $sr->multiply( 0.02, 0.02 ), 0.0004, 'small multiply' );

# I try not to be negative, but these things happen.
is( $sr->multiply( 1.1,  -2.2 ), -2.42, 'negative' );
is( $sr->multiply( -1.1, -2.2 ), 2.42,  'not negative' );

is( $sr->multiply( 42, 31,  28,  215 ),  7850000,  'chain multiply' );
is( $sr->multiply( 42, -31, -28, -215 ), -7850000, 'chain multiply neg' );

plan tests => 11;
