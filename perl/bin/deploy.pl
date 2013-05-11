#!/usr/bin/env perl

use Modern::Perl;

use iCPAN;

my $icpan = iCPAN->new;
$icpan->db_file( '../iCPAN.sqlite' );
$icpan->schema->deploy;
