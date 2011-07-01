package iCPAN::Role::Common;

use Moose::Role;

has 'debug' => (
    is         => 'rw',
    lazy_build => 1,
);

sub _build_debug {

    my $self = shift;
    return $ENV{'DEBUG'} || 0;

}

1;
