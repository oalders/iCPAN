#!perl

use Modern::Perl;
use Data::Dump qw( dump );
use Find::Lib '../lib';
use iCPAN;
use Time::HiRes qw( gettimeofday tv_interval );

my $icpan = iCPAN->new;
$icpan->debug( $ENV{'DEBUG'} );

my @modules = @ARGV;

if ( scalar @modules == 0 ) {
    my $index = $icpan->pkg_index;
    @modules = sort keys %{$index};
}

MODULE:
foreach my $module_name ( @modules ) {

    my $t0 = [ gettimeofday];
    say "$module_name" if $icpan->debug;
    $icpan->module_name( $module_name );
    $icpan->module->process;

    my $elapsed = tv_interval( $t0, [gettimeofday] );
    say "$elapsed time gone" if $icpan->debug;
}
