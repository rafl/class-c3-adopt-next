use strict;
use warnings;
use inc::Module::Install;

name 'Class-C3-Adopt-NEXT';
all_from 'lib/Class/C3/Adopt/NEXT.pm';

requires 'Class::C3';
requires 'NEXT';

postamble(<<"EOM");
testcover: pm_to_blib
\tcover -delete
\tHARNESS_PERL_SWITCHES=-MDevel::Cover \$(MAKE) test
\tcover
EOM

WriteAll;
