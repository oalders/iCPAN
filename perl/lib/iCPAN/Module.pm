package iCPAN::Module;

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
    is      => 'rw',
    lazy_build => 1,
);

has 'icpan' => (
    is      => 'rw',
    default => sub { return iCPAN->new() },
);

has 'name' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'path' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'pauseid' => (
    is         => 'ro',
    required => 1,
    lazy_build => 1,
);

has 'pm_name' => (
    is         => 'rw',
    lazy_build => 1,
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

sub _build_author {

    my $self = shift;
    my $author
        = $self->icpan->schema->resultset( 'iCPAN::Schema::Result::Zauthor' )
        ->find( { zpauseid => $self->pauseid } );

}

sub _build_path {
    my $self = shift;
    return $self->module->{path};
}

sub archive_path {

    my $self         = shift;
    return $self->icpan->minicpan . "/authors/id/" . $self->path;

}

sub process {

    my $self        = shift;
    my $module_name = $self->name;
    my $debug       = $self->debug;

    if ( !$self->author ) {
        say
            "skipping $module_name. cannot find $self->pauseid in author table";
        next;
    }

    # get a list of all files in the .tar archive
    my @files = @{ $self->files };

FILE:

    # locate the file we care about in the archive
    foreach my $file ( @files ) {

        print "checking: $file " if $debug;

        next FILE if !$self->file_ok( $file );

        say "found : $file ";

        $self->parse_pod( $file );

        return;
    }

    $self->icpan->tar->clear; # avoid "Too many open files" errors
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

    my $start_body = qq[<body><div class="pod">];
    $start_body .= qq[<div style="position:fixed;z-index: 5000;height:50px;width:100%;background-color:#fff;"><h1 id="iCPAN">$module_name];
    if ( $self->version ) {
        $start_body .= sprintf(' (%s) ', $self->version );
    }
    $start_body .= qq[</h1><hr /></div><div style="height:50px">&nbsp;</div>];

    $xhtml =~ s{<body>}{$start_body};
    $xhtml =~ s{<\/body>}{<\/div>\n<\/body>};

    $xhtml =~ s{<head>}{<head>\n$head_tags};

    my $module_row
        = $self->icpan->schema->resultset( 'iCPAN::Schema::Result::Zmodule' )
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
    my $root = $self->_module_root;
    my $pattern = qr{$root\.(pm|pod)\z};
    my $extension = undef;

    if ( $file =~ m{$pattern}xms ) {
        $extension = $1;
    }
    else {
        say "skipping --  " . $pm_name . " -- $file" if $self->debug;
        return;
    }

    # not every module contains POD
    my $content = $self->icpan->tar->get_content( $file );
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
    my $tar  = $self->icpan->tar;
    $tar->read( $self->archive_path );
    my @files = $tar->list_files;
    return \@files;

}

sub _build_pm_name {
    my $self         = shift;
    return $self->_module_root . '.pm';
}

sub _build_pod_name {
    my $self         = shift;
    return $self->_module_root . '.pod';
}

sub _build_debug {
    
    my $self = shift;
    return $self->icpan->debug;
    
}

sub _module_root {
    my $self         = shift;
    my @module_parts = split( "::", $self->name );
    return pop( @module_parts ); 
}

1;
