#!/usr/bin/env perl

use strict;
use Find::Lib '../lib', '../../inc/Pod2HTML/lib';
use iCPAN;

my $icpan = iCPAN->new;
$icpan->db_file( '../iCPAN.sqlite' );
$icpan->schema->deploy;
