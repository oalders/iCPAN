#!/bin/sh

minicpan
rm iCPAN.sqlite
cp schema/iCPAN.sqlite .
perl perl/script/load_authors.pl
perl perl/script/load_modules.pl
