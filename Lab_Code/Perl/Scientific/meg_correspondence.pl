#!/usr/bin/perl

##############################################################################
##############################################################################
##
## meg_correspondence.pl
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

use lib "$ENV{MYPERLDIR}/lib"; use lib "$ENV{TIME_FOR_SCIENCE_DIR}/Lab_Code/Perl/LabLibraries"; require "libfile.pl";
use lib "$ENV{MYPERLDIR}/lib"; use lib "$ENV{TIME_FOR_SCIENCE_DIR}/Lab_Code/Perl/LabLibraries"; require "libset.pl";
use lib "$ENV{MYPERLDIR}/lib"; use lib "$ENV{TIME_FOR_SCIENCE_DIR}/Lab_Code/Perl/LabLibraries"; require "libattrib.pl";

use strict;
use warnings;

# Flush output to STDOUT immediately.
$| = 1;

my @flags   = (
                  [    '-q', 'scalar',     0,     1]
              );


my %args = %{&parseArgs(\@ARGV, \@flags, 1)};

if(exists($args{'--help'}))
{
   print STDOUT <DATA>;
   exit(0);
}

my @info    = @{$args{'--extra'}};
my $verbose = not($args{'-q'});

scalar(@info) >= 4 or die("Please supply at least 4 arguments");

my $meg_dir  = shift @info;
my $sets_dir = shift @info;
my @orgs     = @info;

(-d $meg_dir) or die("MetaGene directory '$meg_dir' is not a valid directory name");
(-d $sets_dir) or die("GeneSets directory '$sets_dir' is not a valid directory name");

my @meg_files;
my @sets_files;
my $intersection;
my @m2g;
my @sets2genes;
my @genes;
for(my $i = 0; $i < scalar(@orgs); $i++)
{
   my $org = $orgs[$i];

   my $meg_file  = $meg_dir  . '/' . $org . '/data.meg';
   my $sets_file = $sets_dir . '/' . $org . '/data.tab';

   $verbose and print STDERR "Reading in meta-gene mapping from '$meg_file'...";
   my $meg2genes = &attribRead($meg_file, "\t", 1, 0, 0, 1);

   my $num = &setSize($meg2genes);
   $m2g[$i] = $meg2genes;
   $verbose and print STDERR " done ($num genes read).\n";

   # my %genes;
   # foreach my $meg (keys(%{$meg2genes}))
   # {
   #    foreach my $gene (@{$$meg2genes{$meg}})
   #    {
   #       $genes{$gene} = 1;
   #    }
   # }
   # $genes[$i] = \%genes;

   $verbose and print STDERR "Reading in GeneSet '$sets_file'...";
   my $sets_set = &setsReadMatrix($sets_file, 1, "\t", 0, 1);
   $num = &setSize($sets_set);
   $sets2genes[$i] = $sets_set;
   $verbose and print STDERR " done ($num sets read).\n";

   $verbose and print STDERR "Taking the running intersection.";
   if(defined($intersection))
      { $intersection = &setIntersection($intersection, $sets_set); }
   else
      { $intersection = $sets_set; }

   $num = &setSize($intersection);

   $verbose and print STDERR "Intersection size so far = $num\n";
}

my $meg_union;
my @gene_vecs;
for(my $i = 0; $i < scalar(@orgs); $i++)
{
   $verbose and print STDERR "Inverting sets to create gene vectors.\n";
   my $set_vecs   = &sets2Vectors($sets2genes[$i], [keys(%{$intersection})]);
   $gene_vecs[$i] = &set2List($set_vecs, 1);
   my $num_genes  = scalar(@{$gene_vecs[$i]});
   $verbose and print STDERR "Done creating gene vectors ($num_genes genes).\n";

   my $sizes = &setsSizes($m2g[$i]);
   # $verbose and print STDERR "$orgs[$i]\t", join(" ", @{$sizes}), "\n";

   $meg_union = &setUnion($meg_union, $m2g[$i]);

   my $num = &setSize($meg_union);
   $verbose and print STDERR "Union size = $num\n";
}

my @common_megs = keys(%{$meg_union});
my @common_set_keys = @{&set2List(&setMembers($intersection))};

$verbose and print STDERR join("\n", @common_set_keys);

foreach my $meg (@common_megs)
{


         # print STDOUT join("-",keys(%{$genes})), " :";
	 # my $r = $ranks[$i];
	 # foreach my $gene (keys(%{$r}))
	 # {
	 #    print " $gene=$$r{$gene}";
	 # }
	 # print "\n";

   $verbose and print STDERR "Comparing meta-gene $meg.\n";
   my @matrix;
   for(my $i = 0; $i < scalar(@orgs); $i++)
   {
      my $meg2genes = $m2g[$i];
      my $vecs = $gene_vecs[$i];
      if(exists($$meg2genes{$meg}))
      {
	 my $genes = $$meg2genes{$meg};
	 foreach $gene (keys(%{$genes}))
	 {
	    if(exists($$vecs{$gene}))
	    {
	       push(@matrix, $$vecs{$gene});
	    }

	 }
	 for(my $j = 0; $j < scalar(@orgs); $j++)
	 {
            my $meg2genes_j = $m2g[$j];
	    if($j != $i and exists($$meg2genes_j{$meg}))
	    {
               my $ranks = &rankRelativeToGenes($genes, $gene_vecs[$i], $gene_vecs[$j]);

	       my $ave_rank = 0.0;
	       my $n = 0.0;

	       my $genes_j = $$meg2genes_j{$meg};
	       foreach my $gene (keys(%{$genes_j}))
	       {
	          if(exists($$ranks{$gene}))
	          {
	             $ave_rank += $$ranks{$gene};
	             $n++;
	          }
	       }
	       $ave_rank = $n == 0 ? undef : $ave_rank / $n;
	       push(@ave_ranks, defined($ave_rank) ? $ave_rank : "");

	       if(defined($ave_rank))
	       {
		  $nn++;
		  $ave_ave_rank += $ave_rank;
	       }
	    }
	 }
	 $ave_ave_rank = $nn == 0 ? undef : $ave_ave_rank / $nn;
	 push(@ave_ave_ranks, defined($ave_ave_rank) ? $ave_ave_rank : "");

	 if(defined($ave_ave_rank))
	 {
	    $nnn++;
	    $ave_ave_ave_rank += $ave_ave_rank;
	 }
      }
   }

   $ave_ave_ave_rank = $nnn == 0 ? undef : $ave_ave_ave_rank / $nnn;

   print STDOUT $meg, "\t",
		(defined($ave_ave_ave_rank) ? $ave_ave_ave_rank : ""), "\t",
                join("\t", @ave_ranks), "\t",
		join("\t", @ave_ave_ranks), "\n";

   $verbose and print STDERR "Done comparing meta-gene $meg.\n";
}
$verbose and print STDERR "Done comparing.\n";

exit(0);

# \%attrib rankRelativeToGenes(\%set genes, \@\@list gene_vecs1, \@\@list gene_vecs2);
sub rankRelativeToGenes
{
   my ($genes, $gene_vecs1, $gene_vecs2) = @_;

   my %ranks;

   # Get the vectors for these genes.
   my @centers;
   foreach my $vec (@{$gene_vecs1})
   {
      if(exists($$genes{$$vec[0]}))
      {
         push(@centers, $vec);
      }
   }

   my @dots;
   foreach my $vec (@{$gene_vecs2})
   {
      if(not(exists($$genes{$$vec[0]})))
      {
         my $dot = &meanDotProduct(\@centers, $vec);
         push(@dots, [$$vec[0], $dot]);
      }
   }

   my @sorted_dots = sort by_second_decreasing @dots;
   my $rank = 0;
   my $previous_dot = undef;
   for(my $i = 0; $i < scalar(@sorted_dots); $i++)
   {
      my $vec = $sorted_dots[$i];

      my $dot = $$vec[1];

      if(not(defined($previous_dot)) or $dot != $previous_dot)
      {
         $rank++;
      }

      $ranks{$$vec[0]} = $rank;

      $previous_dot = $dot;
   }

   return \%ranks;
}

sub by_second_decreasing
{
   return ((not(defined($$a[1])) or not(defined($$b[1]))) ? 0 : $$b[1] <=> $$a[1]);
}

# $double meanDotProduct(\@\@list centers, \@list x)
sub meanDotProduct
{
   my ($centers, $x) = @_;

   my $sum_dot = 0.0;
   my $n = 0;
   foreach my $center (@{$centers})
   {
      my $dot = &dotProduct($center, $x);
      $n++;
      $sum_dot += $dot;
   }
   my $mean_dot = $n > 0 ? $sum_dot / $n : undef;

   return $mean_dot;
}

# $double dotProduct(\@list x, \@list y)
sub dotProduct
{
   my ($x, $y) = @_;

   my $xvec = $$x[1];
   my $yvec = $$y[1];
   my $dot = 0.0;
   for(my $i = 0; $i < scalar(@{$xvec}); $i++)
   {
      if(defined($$yvec[$i]))
      {
         $dot += $$xvec[$i] * $$yvec[$i];
      }
   }
   return $dot;
}

__DATA__
syntax: meg_correspondance.pl [OPTIONS] MEG_DIR SETS_DIR ORG1 ORG2 [ORG3...]

MEG_DIR: Location in MAP where the meta-genes are (e.g. ~/Map/Data/MetaGene).

SETS_DIR: Location in MAP where the gene sets are (e.g. ~/Map/Data/GeneSets/Go).

ORGi: Organisms to included in the analysis.

OPTIONS are:

-q: Quiet mode (default is verbose)

