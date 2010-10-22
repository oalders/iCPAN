package iCPAN::MetaIndex;

use Moose;

with 'iCPAN::Role::DB';

use Data::Dump qw( dump );
use iCPAN::Meta::Schema;
use Modern::Perl;

has 'db_path' => (
    is      => 'rw',
    isa     => 'Str',
    default => '../../iCPAN-meta.sqlite',
);

1;
