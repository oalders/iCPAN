use strict;
use warnings;

use iCPAN;
use Test::More;

my $iCPAN = iCPAN->new( debug => 1 );

my $name = 'HTML-Restrict';

my $dist = $iCPAN->schema->resultset('Zdistribution')
    ->search( { zname => $name } )->single;

ok( $dist, "found $name" );
my $found = $iCPAN->update_pod_in_single_dist($dist),
    'update_pod_in_single_dist';
ok( $found, "got pod for $found modules" );

done_testing;
