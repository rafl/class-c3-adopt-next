use strict;
use warnings;
use inc::Module::Install;

name 'Class-C3-Adopt-NEXT';
all_from 'lib/Class/C3/Adopt/NEXT.pm';

requires 'MRO::Compat';
requires 'NEXT';
requires 'List::MoreUtils';

test_requires 'Test::Exception' => '0.27';

repository 'git://github.com/rafl/class-c3-adopt-next.git';
bugtracker 'http://rt.cpan.org/Public/Dist/Display.html?Name=Class-C3-Adopt-NEXT';

extra_tests;

postamble(<<"EOM");
testcover: pm_to_blib
\tcover -delete
\tAUTHOR_TESTING=0 HARNESS_PERL_SWITCHES=-MDevel::Cover \$(MAKE) test
\tcover
EOM

WriteAll;
