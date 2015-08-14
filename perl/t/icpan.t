#!/usr/bin/env perl

use Modern::Perl;
use Test::More;

use Cwd;
use Find::Lib '../../inc/Pod2HTML/lib';
use iCPAN;

new_ok('iCPAN');
my $icpan = iCPAN->new;

isa_ok( $icpan->es,   'ElasticSearch' );
isa_ok( $icpan->mech, 'WWW::Mechanize' );

done_testing();
