#!/usr/bin/perl

# Changes a bed/whatever input file from something like this, where the inputs either do or do not NOT contain 'chr':

# Like:
# 1
# 2
# 2
# MT
# MT
# MT

# or:
# chr1
# chr2
# chrUn_something

# To THIS, where the inputs are listed both as starting with 'chr' and NOT starting with 'chr':

# 1
# chr1
# chr2
# chr3
# chr_UNKNOWN_c
# UNKNOWN_c

# Note that this can change the sort order, which is why we re-sort it!

# This should work on both BED and GTF files---anything with the format "CHR  <tab>  START   <tab>   STOP"

use strict;
use warnings;

print STDERR "Note: this is a pretty dubious script! Read the docs in the source. It SORTS the output also!\nThis script can take a while to run (10 minutes or so on a large file)...\n";

my $FILE_IN = $ARGV[0];
# output goes to STDOUT

my $NOCHR = "${FILE_IN}.nochr.alex.temp.sorting.file.delete.soon.tmp"; # temp file with lines that have the leading 'chr' text removed

system("sed 's/^chr//' $FILE_IN > $NOCHR");
system("sed 's/^/chr/' $NOCHR | cat - $NOCHR | sort -t '\t' -k1,1 -k2,2n"); # prints to stdout. Assumes files are TAB DELIMITED.

system("/bin/rm $NOCHR"); # delete the temp file

