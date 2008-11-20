#!perl -w
use strict;
use warnings;
use Test::More;

eval 'use Test::Spelling 0.11';
plan skip_all => 'Test::Spelling 0.11 not installed' if $@;
plan skip_all => 'set TEST_SPELLING to enable this test' unless $ENV{TEST_SPELLING};

set_spell_cmd('aspell list');

add_stopwords( grep { defined $_ && length $_ } <DATA>);

all_pod_files_spelling_ok();

__DATA__
Florian
Ragwitz
plugins
MRO
practices
runtime
Doran
