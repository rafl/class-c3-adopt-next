use strict;
use warnings;
use Test::More tests => 8;
use Test::Exception;

BEGIN { use_ok('Class::C3::Adopt::NEXT'); }

{
    package C3NT::Foo;

    sub new { return bless {} => shift }

    sub basic        { 42 }
    sub c3_then_next { 21 }
    sub next_then_c3 { 22 }
}

{
    package C3NT::Bar;

    use base qw/C3NT::Foo/;

    sub basic               { shift->NEXT::basic                       }
    sub next_then_c3        { shift->next::method                      }
    sub actual_fail_halfway { shift->NEXT::ACTUAL::actual_fail_halfway }
}

{
    package C3NT::Baz;

    use base qw/C3NT::Foo/;

    sub basic        { shift->NEXT::basic        }
    sub c3_then_next { shift->NEXT::c3_then_next }
}

{
    package C3NT::Quux;

    use base qw/C3NT::Bar C3NT::Baz/;

    sub basic               { shift->NEXT::basic                       }
    sub non_exist           { shift->NEXT::non_exist                   }
    sub non_exist_actual    { shift->NEXT::ACTUAL::non_exist_actual    }
    sub actual_fail_halfway { shift->NEXT::ACTUAL::actual_fail_halfway }
    sub c3_then_next        { shift->next::method                      }
    sub next_then_c3        { shift->NEXT::next_then_c3                }
}

my $quux_obj = C3NT::Quux->new;

# Test 1, the very basics
is($quux_obj->basic, 42, 'Basic inherited method returns correct value');

# Tests 2+3, what happens with no underlying method
{
    my $non_exist_rval;
    lives_ok(sub {
        $non_exist_rval = $quux_obj->non_exist;
    }, 'Non-existant non-ACTUAL throws no errors');
    is($non_exist_rval, undef, 'Non-existant non-ACTUAL returns undef');
}

# Test 4, again, but using ACTUAL
throws_ok(sub {
    $quux_obj->non_exist_actual;
}, qr|^No next::method 'non_exist_actual' found for C3NT::Quux|, 'Non-existant ACTUAL throws correct error');

# Test 5, again, but using ACTUAL, and failing halfway down the stack
throws_ok(sub {
    $quux_obj->actual_fail_halfway;
}, qr|^No next::method 'actual_fail_halfway' found for C3NT::Quux|, 'Non-existant ACTUAL in superclass throws correct error');

# Tests 6+7, C3/NEXT mixing
is( $quux_obj->c3_then_next, 21, 'C3 then NEXT' );
is( $quux_obj->next_then_c3, 22, 'NEXT then C3' );
