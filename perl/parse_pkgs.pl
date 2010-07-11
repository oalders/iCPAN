#!perl

use Modern::Perl;

use Archive::Tar;
use Data::Dump qw( dump );
use File::Path qw( make_path );
use Find::Lib 'lib';
use IO::File;
use IO::Uncompress::AnyInflate qw(anyinflate $AnyInflateError);
use iCPAN;
use iCPAN::Pod;

my $minicpan = "$ENV{'HOME'}/minicpan" || shift @ARGV;
my $file     = "$minicpan/modules/02packages.details.txt.gz";
my $tar      = Archive::Tar->new;

my $z = new IO::Uncompress::AnyInflate $file
    or die "anyinflate failed: $AnyInflateError\n";

my $base  = Find::Lib->base;
my $count = 0;
my $debug = $ENV{'DEBUG'};
my $iCPAN = iCPAN->new;
my $off   = 1;
my $schema = $iCPAN->schema;

chdir $base or die $!;

LINE:
while ( my $line = $z->getline() ) {

    ++$count;
    next if $count < 10;    # skip irrelevant lines
    chomp $line;
    say "********** " . $line;

    my ( $module_name, $version, $archive_path ) = split m{\s{1,}}xms, $line;

    my @parts = split( "/", $archive_path );
    my $pauseid = $parts[2];

    my $author = $schema->resultset( 'iCPAN::Schema::Zauthor' )
        ->find( { zpauseid => $pauseid } );

    if ( !$author ) {
        say "skipping $line ($pauseid). cannot find in author table";
        next;
    }
    
    my $filename = $iCPAN->mod2file( $module_name );

    my @module_parts = split( "::", $module_name );
    my $pm_name = pop( @module_parts ) . '.pm';

    # the directory tree to create is everything up to the final slash
    my $dir = $filename;
    $dir =~ s{\/[.\w]*\z}{};
    $dir =~ s{\.html\z}{};     # some modules are only one folder deep

    #$off = 0 if ( $off && $module eq $start );
    #next if $off;

    my $archive = "$minicpan/authors/id/" . $archive_path;

    # get a list of all files in the .tar archive
    $tar->read( $archive );
    my @files = $tar->list_files;

    # locate the file we care about in the archive
    foreach my $file ( @files ) {

        say "checking: $file" if $debug;

        if ( $file !~ m{$pm_name\z} ) {
            say "skipping --  " . $pm_name . " -- $file" if $debug;
            next;
        }

        # not every module contains POD
        my $content = $tar->get_content( $file );
        if ( !$content || $content !~ m{=head} ) {
            say "skipping -- no POD    -- $file" if $debug;
            next LINE;
        }

        if ( $content !~ m{package\s*$module_name} ) {
            say "skipping -- not the correct package name" if $debug;
            next;
        }

        say "found : $file ";

        # get a relative path for CSS etc
        my $slashes = () = $filename =~ m{/}gxms;
        my $base_href = '../' x $slashes;

        my $html_file = $base . '/html/' . $filename;

        if ( $slashes > 0 ) {
            say "making path " . $dir if $debug;
            make_path( $base . '/html/' . $dir, { verbose => 0 } );
        }

        my $parser = iCPAN::Pod->new();
        #$parser->icpan_base_href( $base_href );
        $parser->perldoc_url_prefix( '' );
        $parser->index( 1 );
        $parser->html_css( 'style.css' );

        #$parser->html_header_tags(qq[<base href="$base_href">]);

        say "opening $html_file";

        # filehandle must be created *before* parsing begins
        open TXTOUT, ">$html_file" or die "Can't write to $html_file: $!";
        my $xhtml = "";
        $parser->output_string( \$xhtml );
        $parser->parse_string_document( $content );

        # do some modifications to the html before outputting to the file
        $xhtml =~ s{<body>}{<body>\n<div class="pod">};
        $xhtml =~ s{<\/body>}{<\/div>\n<\/body>};

        #print TXTOUT sprintf( "%s", $xhtml );
        close TXTOUT;
        
        my $module = $schema->resultset( 'iCPAN::Schema::Zmodule' )->find_or_create(
            {   zauthor => $author->z_pk,
                zname   => $module_name,
            }
        );
    
        if ( $version && $version ne 'undef' ) {
            $module->zversion( $version );
        }
        else {
            $module->zversion( undef );
        }
        
        $module->zpod( $xhtml );
        $module->update;
        
        next LINE;


    }

}

