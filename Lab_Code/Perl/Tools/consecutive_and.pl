#!/usr/bin/perl

##############################################################################
##############################################################################
##
## consecutive_and.pl
##
##############################################################################
##############################################################################
##
## Written by Josh Stuart in the lab of Stuart Kim, Stanford University.
##
##  Email address: jstuart@stanford.edu
##          Phone: (650) 725-7612
##
## Postal address: Department of Developmental Biology
##                 Beckman Center Room B314
##                 279 Campus Dr.
##                 Stanford, CA 94305
##
##       Web site: http://www.smi.stanford.edu/people/stuart
##
##############################################################################
##############################################################################
##
## Written: 00/00/02
## Updated: 00/00/02
##
##############################################################################
##############################################################################

use strict;

use lib "$ENV{MYPERLDIR}/lib"; use lib "$ENV{TIME_FOR_SCIENCE_DIR}/Lab_Code/Perl/LabLibraries"; require "libfile.pl";


use strict;

my $verbose = 1;
my $col     = 1;
my $delim   = "\t";
my @files;
my $headers = 1;

while(@ARGV)
{
   my $arg = shift @ARGV;
   if($arg eq '--help')
   {
      print STDOUT <DATA>;
      exit(0);
   }
   elsif(-f $arg)
   {
      push(@files, $arg);
   }
   elsif($arg eq '-q')
   {
      $verbose = 0;
   }
   elsif($arg eq '-k')
   {
      $col = int(shift @ARGV);
   }
   elsif($arg eq '-d')
   {
      $delim = shift @ARGV;
   }
   elsif($arg eq '-h')
   {
      $headers = shift @ARGV;
   }
   else
   {
      die("Invalid argument '$arg'");
   }
}

$col--;

if($#files == -1)
{
   push(@files,'-');
}

foreach my $file (@files)
{
   my $filep;
   open($filep, $file) or die("Could not open file '$file' for reading");
   my $line = 0;
   my @previous;
   while(<$filep>)
   {
      $line++;

      if($line > $headers)
      {
         my @tuple = split($delim, $_);
         chomp($tuple[$#tuple]);
         my $key = $col >= 0 ? splice(@tuple, $col, 1) : undef;

         my @result;
         if($line == $headers + 1)
         {
            @previous = @tuple;
            @result = @tuple;
         }
         else
         {
            @result = &listAnd(\@previous, \@tuple);
         }

         print STDOUT (defined($key) ? "$key\t" : ""), join($delim, @result), "\n";
      }
      else
      {
         print STDOUT $_;
      }
   }
   close($filep);
}

exit(0);

sub listAnd
{
   my ($one, $two) = @_;

   my @result;

   my $len1    = scalar(@{$one});
   my $len2    = scalar(@{$two});
   my $max_len = $len1 > $len2 ? $len1 : $len2;

   for(my $i = 0; $i < $max_len; $i++)
   {
      $result[$i] = ($i < $len1 and $i < $len2) ? $$one[$i] * $$two[$i] : 0;
   }
   return @result;
}

__DATA__
syntax: consecutive_and.pl [OPTIONS]

OPTIONS are:

-q: Quiet mode (default is verbose)

-k COL: Compare the values in column COL to the threshold in the file (default is 1).

-d DELIM: Set the field delimiter to DELIM (default is tab).

-h HEADERS: Set the number of header lines to HEADERS (default is 1).


