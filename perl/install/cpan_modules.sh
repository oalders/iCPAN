#!/bin/sh

# This script should install most of the required CPAN modules.  If you find
# any modules are missing from this script, please add them.

cpanm --skip-installed Archive::Tar
cpanm --skip-installed CPAN::DistnameInfo
cpanm --skip-installed DBI
cpanm --skip-installed DBIx::Class
cpanm --skip-installed DBIx::Class::Schema::Loader
cpanm --skip-installed Every
cpanm --skip-installed Find::Lib
cpanm --skip-installed HTML::Entities
cpanm --skip-installed IO::File
cpanm --skip-installed IO::Uncompress::AnyInflate
cpanm --skip-installed Modern::Perl
cpanm --skip-installed Moose
cpanm --skip-installed Parse::CSV
cpanm --skip-installed Path::Class::File
cpanm --skip-installed Perl::Tidy
cpanm --skip-installed Pod::Simple::XHTML
