#!/usr/bin/perl

use lib "$ENV{MYPERLDIR}/lib"; use lib "$ENV{TIME_FOR_SCIENCE_DIR}/Lab_Code/Perl/LabLibraries"; require "libmap.pl";

my $pwd = "$ENV{PWD}";

my @orgs = &getMapOrganismNames();

foreach my $org (@orgs)
{
  system("mkdir -p $org");
}

