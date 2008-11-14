use strict;
use warnings;

package Class::C3::Adopt::NEXT;

use NEXT;
use Class::C3;
use warnings::register;

our $VERSION = '0.01';

{
    my %c3_mro_ok;

    {
        my $orig = NEXT->can('AUTOLOAD');

        no warnings 'redefine';
        *NEXT::AUTOLOAD = sub {
            my $class = ref $_[0] || $_[0];

            my $wanted = our $AUTOLOAD || 'NEXT::AUTOLOAD';
            my ($wanted_class) = $wanted =~ m{(.*)::};

            unless (exists $c3_mro_ok{$class}) {
                eval { Class::C3::calculateMRO($class) };
                if (my $error = $@) {
                    warn "Class::C3::calculateMRO('${class}') Error: '${error}';"
                    . ' Falling back to plain NEXT.pm behaviour for this class';
                    $c3_mro_ok{$class} = 0;
                }
                else {
                    $c3_mro_ok{$class} = 1;
                }
            }

            if ($c3_mro_ok{$class} || !length $c3_mro_ok{$class}) {
                warnings::warnif("${class} is trying to use NEXT, which is crap. use Class::C3 or Moose method modifiers instead.");
            }

            unless ($c3_mro_ok{$class}) {
                $NEXT::AUTOLOAD = $wanted;
                goto &$orig;
            }

            goto &next::method if $wanted_class =~ /^NEXT:.*:ACTUAL/;
            goto &maybe::next::method;
        };
    }

    sub unimport {
        my $class = shift;
        @c3_mro_ok{@_} = ('') x @_;
    }
}

1;
