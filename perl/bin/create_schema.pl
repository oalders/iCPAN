#!/usr/bin/env perl

use Data::Dump qw( dump );
use DBIx::Class::Schema::Loader qw( make_schema_at );
use Find::Lib '../lib';
use Getopt::Long::Descriptive;
use iCPAN;
use Modern::Perl;

my ( $opt, $usage ) = describe_options(
    'my-program %o <some-arg>',
    [ 'constraint=s', "table name regex" ],
    [ 'debug',        "print debugging info" ],
    [   'overwrite-modifications',
        'overwrite modifications (helpful in case of checksum mismatch)'
    ],
    [],
    [ 'help', "print usage message and exit" ],
);

my $icpan = iCPAN->new;

my $args = {
    constraint => $opt->constraint || qr{.*},
    debug => $opt->debug,
    dump_directory          => Find::Lib::base() . '/../lib',
    overwrite_modifications => $opt->overwrite_modifications || 0,
};

say "args: " . dump( $args ) if $opt->debug;

make_schema_at( $icpan->schema_class, $args, [ $icpan->dsn ], );
