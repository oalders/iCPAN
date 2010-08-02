package iCPAN::Module;

use Archive::Tar;
use Moose;
use Modern::Perl;
use Data::Dump qw( dump );
use iCPAN;

has 'author' => (
    is         => 'ro',
    isa        => 'iCPAN::Schema::Result::Zauthor',
    lazy_build => 1,
);

has 'content' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'debug' => (
    is         => 'rw',
);

has 'icpan' => (
    is      => 'rw',
    default => sub { return iCPAN->new() },
);

has 'name' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'archive' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'file' => (
    is         => 'rw',
);

has 'pauseid' => (
    is         => 'ro',
    required   => 1,
    lazy_build => 1,
);

has 'pm_name' => (
    is         => 'rw',
    lazy_build => 1,
);

has 'schema' => (
    is         => 'rw',
#    lazy => 1,
);

has 'version' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'files' => (
    is         => 'ro',
    isa        => "ArrayRef",
    lazy_build => 1,
);

has 'tar' => (
    is      => 'rw',
    lazy_build    => 1,
);

sub _build_author {

    my $self = shift;
    
    die "no pauseid" if !$self->pauseid;
    my $author
        = $self->schema->resultset( 'iCPAN::Schema::Result::Zauthor' )
        ->find_or_create( { zpauseid => $self->pauseid } );
    return $author;

}

sub _build_path {
    my $self = shift;
    return $self->module->{archive};
}

sub archive_path {

    my $self = shift;
    return $self->icpan->minicpan . "/authors/id/" . $self->archive;

}

sub process {

    my $self        = shift;
    my $module_name = $self->name;
    my $debug       = $self->debug;

    if ( !$self->author ) {
        say
            "skipping $module_name. cannot find $self->pauseid in author table";
        return;
    }

    #my $iter = Archive::Tar->iter( $self->archive_path, 1,
    #    { filter => qr/\.(pm|pod)$/ } );

    my @files = @{ $self->files };

FILE:

    # locate the file we care about in the archive
    foreach my $file ( @files ) {
    #while ( my $f = $iter->() ) {

        #my $file = $f->name;
        print "checking: $file " if $debug;

        next FILE if !$self->file_ok( $file );

        say "found : $file ";
        $self->file( $file );

        $self->parse_pod( $file );

        $self->tar->clear;
        return;
    }

    $self->tar->clear if $self->tar; 
    warn $self->name . " no success!!!!!!!!!!!!!!!!";

    return;

}

sub parse_pod {

    my $self        = shift;
    my $file        = shift;
    my $content     = $self->content;
    my $module_name = $self->name;
    my $parser      = iCPAN::Pod->new();

    $parser->perldoc_url_prefix( '' );
    $parser->index( 1 );
    $parser->html_css( 'style.css' );

    my $xhtml = "";
    $parser->output_string( \$xhtml );
    $parser->parse_string_document( $content );

    # modify HTML directly

    my $head_tags = '
<link rel="stylesheet" type="text/css" media="all" href="shCore.css" />
<link rel="stylesheet" type="text/css" media="all" href="shThemeEmacs.css" />
</style>
<script type="text/javascript" src="jquery.min.js"></script>
<script type="text/javascript" src="shCore.js"></script>
<script type="text/javascript" src="shBrushPerl.js"></script>
<script type="text/javascript">
    $(document).ready(function() {
        $("pre").wrap(\'<div style="padding: 1px 10px; background-color: #000;" />\').addClass("brush: pl");
        SyntaxHighlighter.defaults[\'gutter\'] = false;
        SyntaxHighlighter.all();
    });
</script>
';
#        SyntaxHiglighter.defaults[\'toolbar\'] = false;

    my $start_body = qq[<body><div class="pod">];
    $start_body
        .= qq[<div style="position:fixed;z-index: 5000;height:50px;width:100%;background-color:#fff;"><h1 id="iCPAN">$module_name];
    if ( $self->version ) {
        $start_body .= sprintf( ' (%s) ', $self->version );
    }
    $start_body .= qq[</h1><hr /></div><div style="height:50px">&nbsp;</div>];

    $xhtml =~ s{<body>}{$start_body};
    $xhtml =~ s{<\/body>}{<\/div>\n<\/body>};

    $xhtml =~ s{<head>}{<head>\n$head_tags};

    my $module_row
        = $self->schema->resultset( 'iCPAN::Schema::Result::Zmodule' )
        ->find_or_create( { zname => $module_name, } );

    # author may have changed since last version
    $module_row->zauthor( $self->author->z_pk );

    my $version = $self->version;
    if ( $version && $version ne 'undef' ) {
        $module_row->zversion( $version );
    }
    else {
        $module_row->zversion( undef );
    }

    $module_row->zpod( $xhtml );
    $module_row->update;

}

sub file_ok {

    my $self        = shift;
    my $module_name = $self->name;
    my $file        = shift;
    my $pm_name     = $self->pm_name;

    # look for a .pm or .pod file
    # DBM::Deep is an example of a distro with a .pod file (Deep.pod)
    my $root      = $self->_module_root;
    my $pattern   = qr{$root\.(pm|pod)\z};
    my $extension = undef;

    if ( $file =~ m{$pattern}xms ) {
        $extension = $1;
    }
    else {
        say "skipping --  " . $pm_name . " -- $file" if $self->debug;
        return;
    }

    # not every module contains POD
    my $content = $self->tar->get_content( $file );
    if ( !$content || $content !~ m{=head} ) {
        say "skipping -- no POD    -- $file" if $self->debug;
        return;
    }

    if ( $extension ne 'pod' && $content !~ m{package\s*$module_name} ) {
        say "skipping -- not the correct package name" if $self->debug;
        return;
    }

    $self->content( $content );
    return $content;

}

sub _build_files {

    my $self = shift;
    my $tar  = $self->tar;
    
    eval { $tar->read( $self->archive_path ) };
    if ( $@ ) {
        warn $@;
        return [];
    }
    
    my @files = $tar->list_files;
    return \@files;

}

sub _build_pm_name {
    my $self = shift;
    return $self->_module_root . '.pm';
}

sub _build_pod_name {
    my $self = shift;
    return $self->_module_root . '.pod';
}

sub _build_tar {
    
    my $self = shift;
    say "archive path: " . $self->archive_path if $self->debug;
    return Archive::Tar->new( $self->archive_path );
    
}

sub _module_root {
    my $self = shift;
    my @module_parts = split( "::", $self->name );
    return pop( @module_parts );
}

1;
