#!/bin/sh

if [ ! -f 'script/new_database.sh' ];
then
echo "This script must be run from the iCPAN/perl directory"
echo "Usage: sh script/new_database.sh"
exit 0
fi

cd ..

minicpan

# the dbs might actually be symlinks, so we don't necessarily want to copy
# a new file over them
mv iCPAN.sqlite iCPAN.sqlite.bak
cp schema/iCPAN.sqlite .

mv iCPAN-meta.sqlite iCPAN.sqlite.bak
cp schema/iCPAN-meta.sqlite .

cd perl

perl script/load_authors.pl
perl script/load_meta.pl
perl script/load_modules.pl
perl script/load_ratings.pl
