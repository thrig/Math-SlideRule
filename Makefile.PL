#!perl

use 5.010000;

use strict;
use warnings;
use ExtUtils::MakeMaker;

my %params = (
  NAME               => 'Math::SlideRule',
  AUTHOR             => q{Jeremy Mates <jmates@cpan.org>},
  VERSION_FROM       => 'lib/Math/SlideRule.pm',
  ABSTRACT_FROM      => 'lib/Math/SlideRule.pm',
  LICENSE            => 'Artistic_2_0',
  PL_FILES           => {},
  CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0, },
  BUILD_REQUIRES     => { 'Test::Exception' => 0, 'Test::More' => 0, },
  PREREQ_PM =>
    { 'Carp' => 0, 'Moo' => 0, 'namespace::clean' => 0, 'Scalar::Util' => 0, },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'Math-SlideRule-*' },
);

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
  $params{META_MERGE} = {
    resources => {
      homepage   => 'http://github.com/thrig/Math-SlideRule',
      license    => 'http://dev.perl.org/licenses/',
      repository => 'http://github.com/thrig/Math-SlideRule',
    }
  };
}

if ( $ExtUtils::MakeMaker::VERSION ge '6.48' ) {
  $params{MIN_PERL_VERSION} = 5.010000;
}

WriteMakefile(%params);
