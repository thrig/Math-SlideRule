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
# Private things, not for public consumption, do not use

is_deeply( [ Math::SlideRule::_normalize(.0055) ], [ 5.5,  -3 ], 'norm-3' );
is_deeply( [ Math::SlideRule::_normalize(.055) ],  [ 5.5,  -2 ], 'norm-2' );
is_deeply( [ Math::SlideRule::_normalize(.55) ],   [ 5.5,  -1 ], 'norm-1' );
is_deeply( [ Math::SlideRule::_normalize(5.55) ],  [ 5.55, 0 ],  'norm0' );
is_deeply( [ Math::SlideRule::_normalize(55.5) ],  [ 5.55, 1 ],  'norm1' );
is_deeply( [ Math::SlideRule::_normalize(555) ],   [ 5.55, 2 ],  'norm2' );
is_deeply( [ Math::SlideRule::_normalize(5550) ],  [ 5.55, 3 ],  'norm3' );

# meh, just sprintf "%.2f" for any n<3
ok( Math::SlideRule::_round(1) == 1.00,     'round <3 @ 1' );
ok( Math::SlideRule::_round(1.234) == 1.23, 'round <3 @ 1.234' );
ok( Math::SlideRule::_round(1.236) == 1.24, 'round <3 @ 1.236' );

# tricker rounding involved for n<5 and implicit n<10
ok( Math::SlideRule::_round(4) == 4.00,       'round <5 @ 4' );
ok( Math::SlideRule::_round(4.0375) == 4.025, 'round <5 @ 4.0375' );
ok( Math::SlideRule::_round(4.0376) == 4.05,  'round <5 @ 4.0376' );
ok( Math::SlideRule::_round(9) == 9.00,       'round <10 @ 9' );
ok( Math::SlideRule::_round(9.025) == 9.00,   'round <10 @ 9.025' );
ok( Math::SlideRule::_round(9.026) == 9.05,   'round <10 @ 9.026' );

########################################################################
#
# Public attributes

ok( $sr->C(4.1) );
ok( $sr->D(3.7) );

ok( $sr->clear_C() );
dies_ok { $sr->C("number six") } 'number not a name';

ok( $sr->clear_D() );
dies_ok { $sr->D("number one") } 'who is number one?';

########################################################################
#
# Public methods

is( $sr->multiply( 1.1, 2.2 ), 2.42, 'simple multiply' );
is( $sr->multiply( 4.1, 3.7 ), 15.2, 'magnitude shift result' );
is( $sr->multiply( 99,  99 ),  9800, 'big multiply' );

# TODO small multiply, tests where one exp pos, other neg, etc.

plan tests => 27;
