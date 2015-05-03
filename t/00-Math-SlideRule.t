#!perl

use strict;
use warnings;

use Test::More;    # plan is down at bottom
use Test::Exception;

BEGIN {
  use_ok('Math::SlideRule') || print "Bail out!\n";
}
diag("Testing Math::SlideRule $Math::SlideRule::VERSION, Perl $], $^X");

my $sr = Math::SlideRule->new;
isa_ok( $sr, 'Math::SlideRule' );

########################################################################
#
# Public attributes

# Back! Though are lookup tables now, so uh yeah.

########################################################################
#
# Public methods

# subclasses shouldn't normally override this, so tested only here
is_deeply( [ $sr->standard_form(.0055) ], [ 5.5,  -3, 0 ], 'norm-3' );
is_deeply( [ $sr->standard_form(.055) ],  [ 5.5,  -2, 0 ], 'norm-2' );
is_deeply( [ $sr->standard_form(.55) ],   [ 5.5,  -1, 0 ], 'norm-1' );
is_deeply( [ $sr->standard_form(5.55) ],  [ 5.55, 0,  0 ], 'norm0' );
is_deeply( [ $sr->standard_form(55.5) ],  [ 5.55, 1,  0 ], 'norm1' );
is_deeply( [ $sr->standard_form(555) ],   [ 5.55, 2,  0 ], 'norm2' );
is_deeply( [ $sr->standard_form(5550) ],  [ 5.55, 3,  0 ], 'norm3' );
is_deeply( [ $sr->standard_form(-640) ],  [ 6.40, 2,  1 ], 'norm4' );

# do need to check these...
is( sprintf( "%.2f", $sr->divide( 75, 92 ) ), 0.82, 'simple divide' );
is( sprintf( "%.2f", $sr->divide( 14, 92, 3 ) ), 0.05, 'chain divide' );

is( sprintf( "%.2f", $sr->multiply( 1.1, 2.2 ) ), 2.42, 'simple multiply' );
is( sprintf( "%.2f", $sr->multiply( 4.1, 3.7 ) ),
  15.17, 'multiply across bounds' );

# actual answer precisely 4.00e-4; similar calculations without so nice
# numbers would require rounding...
is( sprintf( "%.4f", $sr->multiply( 0.02, 0.02 ) ), 0.0004,  'small multiply' );

# this is probably near a worst case for accuracy, given the infrequent
# ticks at the high end of the scale; 9799.41 vs. expected 9801, so
# really do need to round things
is( sprintf( "%.2f", $sr->multiply( 99, 99 ) ),   9799.41, 'big multiply' );

# I try not to be negative, but these things happen.
is( sprintf( "%.2f", $sr->multiply( 1.1,  -2.2 ) ), -2.42, 'negative' );
is( sprintf( "%.2f", $sr->multiply( -1.1, -2.2 ) ), 2.42,  'not negative' );

# These really do accumulate error without rounding! (TODO investigate
# the error...)
is( sprintf("%.2f", $sr->multiply( 42, 31,  28,  215 )), 7837905.09,  'chain multiply' );
is( sprintf("%.2f", $sr->multiply( 42, -31, -28, -215 )), -7837905.09, 'chain multiply neg' );

plan tests => 20;
