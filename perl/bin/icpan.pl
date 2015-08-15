#!/usr/bin/env perl

# See bin/populate_db.sh for a list of available options

use strict;
use warnings;

use Data::Printer;
use iCPAN;

my $icpan = iCPAN->new_with_options;
$icpan->db_file('../iCPAN.sqlite');
$icpan->search_prefix(q{});
$icpan->dist_search_prefix(q{});
$icpan->purge(1);
$icpan->children(10);

my $schema = $icpan->schema;

p($schema) if $icpan->{debug};

if ($icpan->has_action) {
    my $method = $icpan->action;
    $icpan->$method;
}
