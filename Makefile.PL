use strict;
use warnings;
use inc::Module::Install;

name 'Class-C3-Adopt-NEXT';
all_from 'lib/Class/C3/Adopt/NEXT.pm';

requires 'MRO::Compat';
requires 'NEXT';

test_requires 'Test::Exception';

extra_tests;

postamble(<<"EOM");
testcover: pm_to_blib
\tcover -delete
\tAUTHOR_TESTING=0 HARNESS_PERL_SWITCHES=-MDevel::Cover \$(MAKE) test
\tcover
EOM

WriteAll;
