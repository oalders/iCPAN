package iCPAN::Module;

use Archive::Tar;
use Moose;
use Modern::Perl;
use Data::Dump qw( dump );

has 'debug' => ( is => 'rw', );

has 'name' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'file' => ( is => 'rw', );

has 'version' => (
    is         => 'ro',
    lazy_build => 1,
);


sub process {

    my $self        = shift;
    my $module_name = $self->name;

    print "checking: " . $self->file if $self->debug;

    return 0 if !$self->file_ok( $self->file );

    $self->parse_pod;

    return 1;

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
<link rel="stylesheet" type="text/css" media="all" href="shThemeDefault.css" />
<script type="text/javascript" src="jquery.min.js"></script>
<script type="text/javascript" src="shCore.js"></script>
<script type="text/javascript" src="shBrushPerl.js"></script>
<script type="text/javascript" src="iCPAN.js"></script>
<script type="text/javascript">
    $(document).ready(function() {
        icpan_highlight();
    });
</script>
';

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

1;
