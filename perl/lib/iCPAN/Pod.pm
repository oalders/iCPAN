package iCPAN::Pod;

=head2 SYNOPSIS

We need to mess with the POD links a bit so that everything will work with
relative rather than absolute URLs.

=cut

use Moose;

extends 'Pod::Simple::XHTML';

use Modern::Perl;
use Data::Dump qw( dump );
use HTML::Entities;
use IO::File;
use Path::Class::File;
use Perl::Tidy;

sub start_L {
    my ( $self, $flags ) = @_;
    my ( $type, $to, $section ) = @{$flags}{ 'type', 'to', 'section' };

    my $file = $to;
    if ( $file ) {
        $file =~ s{::}{-}g;
        $file .= '.html' if $file;
    }

    my $url
        = $type eq 'url' ? $to
        : $type eq 'pod' ? $self->resolve_pod_page_link( $file, $section )
        : $type eq 'man' ? $self->resolve_man_page_link( $to, $section )
        :                  undef;

    # If it's an unknown type, use an attribute-less <a> like HTML.pm.
    $self->{'scratch'} .= '<a' . ( $url ? ' href="' . $url . '">' : '>' );
}

sub start_Verbatim {

    #$_[0]{'scratch'} = '<pre><code>'

}

sub end_Verbatim {

    #$_[0]{'scratch'}     .= '</code></pre>';

    my $pygmentize = 1;

    my $filename = '/tmp/iCPAN.code';
    unlink $filename;

    my $code = $_[0]{'scratch'};
    $code = decode_entities( $code );
    my $err = undef;
    my $fh = IO::File->new( \$err, 'w' )
        || die "could not create file handle";
    my @lines = ();
    
    eval {
        perltidy( source => \$code, destination => \@lines, stderr => $fh );        
    };
    
    warn @! if @!;

    if ( !$err && !@! ) {
        $code = join "", @lines;

        if ( $pygmentize ) {

            my $file = Path::Class::File->new( $filename );

            my $fh = $file->openw();
            print $fh $code;
            $fh->close;

            $code = `pygmentize -f html -l perl $filename 2>&1`;
            if ( $code =~ m{Error\swhile\shighlighting}gxms ) {
                $code = '<pre><code>' . $_[0]{'scratch'} . '</code></pre>';
            }
        }
    }
    else {
        $code = encode_entities( $code );
        $code = '<pre><code>' . $_[0]{'scratch'} . '</code></pre>';
    }

    $_[0]{'scratch'} = $code;

    #say $_[0]{'scratch'};
    $_[0]->emit;
}

1;
