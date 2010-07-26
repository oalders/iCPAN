#!/bin/sh

# This script should install most of the CPAN modules required to run the web site.  If you find
# any modules are missing from this script, please add them.

cpanm --skip-installed Dancer
