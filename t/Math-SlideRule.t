#!perl

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

BEGIN {
    use_ok( 'Math::SlideRule' ) || print "Bail out!\n";
}
diag( "Testing Math::SlideRule $Math::SlideRule::VERSION, Perl $], $^X" );

my $sr = Math::SlideRule->new;
isa_ok( $sr, 'Math::SlideRule' );

ok( $sr->C(1.5) );
ok( $sr->D(3.7) );

diag( $sr->look_C_D );

plan tests => 4;
