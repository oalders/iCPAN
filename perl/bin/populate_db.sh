#!/bin/sh

#minicpan

bin/carton bin/icpan.pl --action insert_authors
bin/carton bin/icpan.pl --action insert_distributions
bin/carton bin/icpan.pl --action insert_modules
bin/carton bin/icpan.pl --action pod_by_dist
bin/carton bin/icpan.pl --action finish_db

cd ..
mv iCPAN.sqlite.zip iCPAN.sqlite.zip.old
zip iCPAN.sqlite.zip iCPAN.sqlite
