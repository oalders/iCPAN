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

    my $perltidy   = 0;
    
    # if there's no semicolon, it may not be Perl
    if ( $perltidy && $_[0]{'scratch'} =~ m{;} ) {
        $_[0]{'scratch'} = decode_entities( $_[0]{'scratch'} );
        $_[0]{'scratch'} = tidy_perl( $_[0]{'scratch'} );
        $_[0]{'scratch'} = encode_entities( $_[0]{'scratch'} );
    }

    $_[0]{'scratch'} = '<pre>' . $_[0]{'scratch'} . '</pre>';
    
    #say "going to emit $_[0]{'scratch'}";

    $_[0]->emit;
}

sub tidy_perl {

    my $code = shift;
    my $err  = undef;
    my $fh   = IO::File->new( 'error.txt', 'w' )
        || die "could not create file handle";
    my @lines;
    #say "code i got:" . dump( $code );
    my $orig = $code;

    eval {
        perltidy(
            source      => \$code,
            destination => \@lines,
            stderr      => $fh,
            #perltidyrc  => Find::Lib::base() . '/../.perltidyrc',
        );
    };

    #say "tidied lines: " . dump \@lines;
    warn @! if @!;

    if ( @lines && !$err && !@! ) {
        $code = join "", @lines;
    }
    else {
        use File::Slurp;
        $fh->close;
        say "-------------------> error?";
        print read_file( 'error.txt' );
    }

    return $code;

}

1;
