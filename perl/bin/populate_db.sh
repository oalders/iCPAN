#!/bin/sh

perl bin/icpan.pl --action insert_authors
perl bin/icpan.pl --action insert_distributions
perl bin/icpan.pl --action insert_modules
perl bin/icpan.pl --action pod_by_dist
rm ../iCPAN.sqlite.zip
zip ../iCPAN.sqlite.zip ../iCPAN.sqlite
