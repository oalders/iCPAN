package iCPAN::Module;

use Moose;
use Modern::Perl;
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
    default => 0,
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
    my @module_parts = split( "::", $self->name );
    my $pm_name      = pop( @module_parts ) . '.pm';
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

        say "checking: $file" if $debug;

        next FILE if !$self->file_ok( $file );

        say "found : $file ";

        $self->parse_pod( $file );

        return;
    }

    warn "no success!!!!!!!!!!!!!!!!";
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
    my $start_body = qq[<body><div class="pod">];
    $start_body .= qq[$module_name];
    if ( $self->version ) {
        $start_body .= qq[ ($self->version)];
    }

    $xhtml =~ s{<body>}{$start_body};
    $xhtml =~ s{<\/body>}{<\/div>\n<\/body>};

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

    if ( $file !~ m{$pm_name\z} ) {
        say "skipping --  " . $pm_name . " -- $file" if $self->debug;
        return;
    }

    # not every module contains POD
    my $content = $self->icpan->tar->get_content( $file );
    if ( !$content || $content !~ m{=head} ) {
        say "skipping -- no POD    -- $file" if $self->debug;
        return;
    }

    if ( $content !~ m{package\s*$module_name} ) {
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
    my @module_parts = split( "::", $self->name );
    my $pm_name      = pop( @module_parts ) . '.pm';
    return $pm_name;
}

1;
