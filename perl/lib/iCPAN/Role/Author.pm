package iCPAN::Role::Author;

use Moose::Role;

has 'author' => (
    is         => 'ro',
    isa        => 'iCPAN::Schema::Result::Zauthor',
    lazy_build => 1,
);


sub _build_author {

    my $self = shift;

    die "no pauseid" if !$self->metadata->pauseid;
    my $author = $self->schema->resultset( 'iCPAN::Schema::Result::Zauthor' )
        ->find_or_create( { zpauseid => $self->metadata->pauseid } );
    return $author;

}

1;
