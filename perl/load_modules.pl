#!/usr/bin/perl

use Modern::Perl;

use Data::Dump qw( dump );
use DBI;
use File::Path qw( make_path );
use Find::Lib 'lib';
use iCPAN;
use IO::File;
use IO::Uncompress::AnyInflate qw(anyinflate $AnyInflateError);

use iCPAN::Schema;

my $minicpan = "$ENV{'HOME'}/minicpan" || shift @ARGV;
my $file = "$minicpan/modules/02packages.details.txt.gz";

my $z = new IO::Uncompress::AnyInflate $file
    or die "anyinflate failed: $AnyInflateError\n";

my $iCPAN  = iCPAN->new;
my $schema = iCPAN->schema;

my $count = 0;
while ( my $line = $z->getline() ) {

    ++$count;
    next if $count < 10;
    chomp $line;

    my ( $module, $version, $path ) = split m{\s{1,}}xms, $line;

    my $filename = $iCPAN->mod2file( $module );

    if ( !-e 'html/' . $filename ) {
        say "skipping $module.  POD does NOT exist.";
        next;
    }

    my @parts = split( "/", $path );
    my $pauseid = $parts[2];

    my $author = $schema->resultset( 'iCPAN::Schema::Zauthor' )
        ->find( { zpauseid => $pauseid } );

    if ( !$author ) {
        say "skipping $line ($pauseid). cannot find in author table";
        next;
    }

    $module = $schema->resultset( 'iCPAN::Schema::Zmodule' )->find_or_create(
        {   zauthor => $author->z_pk,
            zname   => $module,
        }
    );

    if ( $version && $version ne 'undef' ) {
        $module->zversion( $version );
    }
    else {
        $module->zversion( undef );
    }

    my $file = "html/$filename";
    my $fh   = new IO::File "< $file" || warn $!;
    my $pod  = '';

    if ( defined $fh ) {
        while ( my $line = $fh->getline ) {
            $pod .= $line;
        }
        $fh->close;
        $module->zpod( $pod );
    }

    $module->update;

}
