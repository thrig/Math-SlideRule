#!perl

use strict;
use warnings FATAL => 'all';

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
#
# subclasses shouldn't normally override these, so tested only here

is( $sr->C(4.1), sprintf( "%.2f", 4.1 ), 'set C' );
# these round
is( $sr->D(1.1119), sprintf( "%.2f", 1.112 ), 'set D' );

ok( $sr->clear_C() );
dies_ok { $sr->C("number six") } 'number not a name';

ok( $sr->clear_D() );
dies_ok { $sr->D("number one") } 'who is number one?';

########################################################################
#
# Public methods

# subclasses shouldn't normally override this, so tested only here
is_deeply( [ $sr->standard_form(.0055) ], [ 5.5,  -3 ], 'norm-3' );
is_deeply( [ $sr->standard_form(.055) ],  [ 5.5,  -2 ], 'norm-2' );
is_deeply( [ $sr->standard_form(.55) ],   [ 5.5,  -1 ], 'norm-1' );
is_deeply( [ $sr->standard_form(5.55) ],  [ 5.55, 0 ],  'norm0' );
is_deeply( [ $sr->standard_form(55.5) ],  [ 5.55, 1 ],  'norm1' );
is_deeply( [ $sr->standard_form(555) ],   [ 5.55, 2 ],  'norm2' );
is_deeply( [ $sr->standard_form(5550) ],  [ 5.55, 3 ],  'norm3' );

# do need to check these...
is( $sr->divide( 75, 92 ), 0.815, 'simple divide' );

is( $sr->multiply( 1.1,  2.2 ),  2.42,   'simple multiply' );
is( $sr->multiply( 4.1,  3.7 ),  15.2,   'magnitude shift result' );
is( $sr->multiply( 99,   99 ),   9800,   'big multiply' );
is( $sr->multiply( 0.02, 0.02 ), 0.0004, 'small multiply' );

# I try not to be negative, but these things happen.
is( $sr->multiply( 1.1,  -2.2 ), -2.42, 'negative' );
is( $sr->multiply( -1.1, -2.2 ), 2.42,  'not negative' );

is( $sr->multiply( 42, 31,  28,  215 ),  7830000,  'chain multiply' );
is( $sr->multiply( 42, -31, -28, -215 ), -7830000, 'chain multiply neg' );

plan tests => 24;
