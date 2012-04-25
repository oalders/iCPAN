#!/usr/bin/env perl

use Modern::Perl;
use Test::More;

use Cwd;
use Find::Lib '../../inc/Pod2HTML/lib';
use iCPAN;

new_ok( 'iCPAN' );

done_testing();
