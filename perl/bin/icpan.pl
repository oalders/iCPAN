#!/usr/bin/env perl

use Modern::Perl;

use Data::Printer;
use Getopt::Long::Descriptive qw( describe_options );
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

p( $schema ) if $opt->{debug};

my $method = $opt->{action};
if ( $method ) {
    $icpan->$method;
}
else {
    say "no method found";
}
