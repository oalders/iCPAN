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

has 'icpan_base_href' => ( is => 'rw' );

sub start_L {
  my ($self, $flags) = @_;
    my ($type, $to, $section) = @{$flags}{'type', 'to', 'section'};
    
    my $file = $to;
    if ( $file ) {
        $file =~ s{::}{-}g;
        $file .= '.html' if $file;        
        #$file = $self->icpan_base_href . $file;        
    }
  
    my $url = $type eq 'url' ? $to
            : $type eq 'pod' ? $self->resolve_pod_page_link($file, $section)
            : $type eq 'man' ? $self->resolve_man_page_link($to, $section)
            :                  undef;

    # If it's an unknown type, use an attribute-less <a> like HTML.pm.
    $self->{'scratch'} .= '<a' . ($url ? ' href="'. $url . '">' : '>');
}

sub start_Verbatim {
    $_[0]{'scratch'} = '<pre><code>'
}

sub end_Verbatim {
    $_[0]{'scratch'}     .= '</code></pre>';
    
    #say $_[0]{'scratch'};
    $_[0]->emit;
}

1;
