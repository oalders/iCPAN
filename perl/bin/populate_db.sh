#!/bin/sh

minicpan

perl bin/icpan.pl --action insert_authors
perl bin/icpan.pl --action insert_distributions
perl bin/icpan.pl --action insert_modules
perl bin/icpan.pl --action pod_by_dist
perl bin/finish_db

cd ..
mv iCPAN.sqlite.zip iCPAN.sqlite.zip.old
zip iCPAN.sqlite.zip iCPAN.sqlite
