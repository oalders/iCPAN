#!/bin/sh

minicpan
rm iCPAN.sqlite
cp schema/iCPAN.sqlite .
perl perl/script/load_authors.pl
perl perl/script/load_meta.pl
perl perl/script/load_modules.pl
perl perl/script/load_ratings.pl
