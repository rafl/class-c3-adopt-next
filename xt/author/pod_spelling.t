use strict;
use warnings;
use Test::Spelling;

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
