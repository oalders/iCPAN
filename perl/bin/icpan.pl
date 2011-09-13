#!/usr/bin/env perl

use Data::Dump qw( dump );
use ElasticSearch;
use Find::Lib '../lib', '../../inc/Pod2HTML/lib';
use Getopt::Long::Descriptive;
use Modern::Perl;
use Scalar::Util qw( reftype );
use iCPAN;

my ( $opt, $usage ) = describe_options(
    'update_db %o <some-arg>',
    [ 'action=s', "method (insert_authors|insert_modules|insert_distributions|update_module_pod)" ],
    [ 'debug',        "print debugging info" ],

    [],
    [ 'help', "print usage message and exit" ],
);

print($usage->text), exit if $opt->help;

my $icpan = iCPAN->new;
$icpan->db_file( '../iCPAN.sqlite' );
$icpan->search_prefix("");
$icpan->dist_search_prefix("");
$icpan->purge(1);
$icpan->children(10);
my $schema = $icpan->schema;

if ( $opt->{debug} ) {
    say dump( $schema );
}

my $method = $opt->{action};
if ( $method ) {
    $icpan->$method;
}
else {
    say "no method found";
}
