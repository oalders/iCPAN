#!/bin/sh

perl bin/icpan.pl --action insert_authors
perl bin/icpan.pl --action insert_distributions 
perl bin/icpan.pl --action insert_modules 
perl bin/icpan.pl --action update_module_pod
