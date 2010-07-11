package iCPAN::Schema;
use base qw/DBIx::Class::Schema::Loader/;

__PACKAGE__->loader_options(
#    constraint              => '^foo.*',
    debug                   => 1,
);
