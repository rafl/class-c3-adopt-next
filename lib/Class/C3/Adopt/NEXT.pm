use strict;
use warnings;

package Class::C3::Adopt::NEXT;

use NEXT;
use Class::C3;
use warnings::register;

our $VERSION = '0.01';

{
    my %c3_mro_ok;
    my %warned_for;

    {
        my $orig = NEXT->can('AUTOLOAD');

        no warnings 'redefine';
        *NEXT::AUTOLOAD = sub {
            my $class = ref $_[0] || $_[0];

            # 'NEXT::AUTOLOAD' is cargo-culted from C::P::C3, I have no idea if/why it's needed
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

            if (length $c3_mro_ok{$class} && $c3_mro_ok{$class}) {
                unless ($warned_for{$class}) {
                    warnings::warnif("${class} is trying to use NEXT, which is crap. use Class::C3 or Moose method modifiers instead.");
                    $warned_for{$class} = 1;
                }
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

__END__

=head1 NAME

Class::C3::Adopt::NEXT

=head1 SYNOPSIS

    package MyApp::Plugin::FooBar;
    #use NEXT;
    use Class::C3::Adopt::NEXT;

    sub a_method {
        my ($self) = @_;
        # Do some stuff

        # Re-dispatch method
        $self->NEXT::method();
    }

=head1 DESCRIPTION

L<NEXT> sucks. I mean, it B<really really sucks>. It was a good solution a few
years ago, but isn't any more.  It's slow, and the order in which it
re-dispatches methods appears random at times. It also encourages bad
programming practices, as you end up with code to re-dispatch methods when all
you really wanted to do was run some code before or after a method fired.

However, if you have a large application, then weaning yourself off C<NEXT> isn't
easy.

This module is intended as a drop-in replacement for NEXT, supporting the same
interface, but using L<Class::C3> to do the hard work. You can then write new
code without C<NEXT>, and migrate individual source files to use C<Class::C3> or
method modifiers as appropriate, at whatever pace you're comfortable with.

=head1 MIGRATING

There are two main reasons for using NEXT:

=over

=item Providing plugins which run functionality before/after your methods.

Use L<Moose> and make all of your plugins L<Moose::Roles|Moose::Role>, then use
method modifiers to wrap methods.

Example:

    package MyApp::Plugin::FooBar;
    use Moose::Role;

    before 'a_method' => {
        my ($self) = @_;
        # Do some stuff
    };

You can then use something like L<MooseX::Traits> or
L<MooseX::Object::Pluggable> to load plugins dynamically.

=item A complex class hierarchy where you actually need multiple dispatch.

Recommended strategy is to find the core class responsible for loading all the
other classes in your application and add the following code:

    use MRO::Compat;
    Class::C3::initialize();

after you have loaded all of your modules.

You then add C<use mro 'c3'> to the top of a package as you start converting it,
and gradually replace your calls to C<NEXT::method()> with
C<maybe::next::method()>, and calls to C<NEXT::ACTUAL::method()> with
C<next::method()>.

On systems with L<Class::C3::XS> present, this will automatically be used to
speed up method re-dispatch. If you are running perl version 5.9.5 or greater
then the C3 method resolution algorithm is included in perl. Correct use
of L<MRO::Compat> as shown above allows your code to be seamlessly forward
and backwards compatible, taking advantage of native versions if available,
but falling back to using pure perl C<Class::C3>.

=back

=head1 CAVEATS

There are some inheritance hierarchies that it is possible to create which
cannot be resolved to a simple C3 hierarchy. In that case, this module will
fall back to using C<NEXT>. In this case a warning will be emitted.

Because calculating the MRO of every class every time C<< ->NEXT::foo >> is used
from within it is too expensive, runtime manipulations of C<@ISA> are prohibited.

=head1 FUNCTIONS

This module replaces C<NEXT::AUTOLOAD> with it's own version. If warnings
are enabled then a warning will be emitted on the first use of C<NEXT> by
each package.

=head1 SEE ALSO

L<MRO::Compat> and L<Class::C3> for method re-dispatch and L<Moose> for
method modifiers and L<roles|Moose::Role>.

L<NEXT> for documentation on the functionality you'll be removing.

=head1 AUTHORS

Florian Ragwitz C<rafl@debian.org>

Tomas Doran C<bobtfish@bobtfish.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
