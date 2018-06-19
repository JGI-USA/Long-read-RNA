#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV > 0){
	die "$0 <gff>\n";
}

my $gff = $ARGV[0];

my $prefix = $gff;
$prefix =~ s/\.gff3//;
$prefix =~ s/\.gff//;

my $gene_pred = "$prefix.genePred";
my $temp1bed = "$prefix.temp1.bed";
my $temp2bed = "$prefix.temp2.bed";
my $bed = "$prefix.bed";
my $gtf = "$prefix.gtf";
my $log = "$prefix.conversion.log";

#make gtf
system("gt gff3_to_gtf $gff > $gtf 2>$log") == 0 or die $!;

#make genepred
system("gff3ToGenePred $gff  -useName -rnaNameAttr=gbkey $gene_pred 2>$log") == 0 or die $!;

#make temp bed
system("genePredToBed $gene_pred $temp1bed 2>$log") == 0 or die $!;

system("bedtools sort -i $temp1bed > $temp2bed 2>$log") == 0 or die $!;

my %newnames;
open(my $gp_fh, $gene_pred) or die $!;
while(<$gp_fh>){
	my($name, $chr, $str, $txS, $txE, $cdsS, $cdsE, $exCt, $exS, $exE, $score, $name2, $cdsSS, $cdsES, $frames) = split/\t/, $_;
	$newnames{$chr}{$str}{$txS} = "$name:$name2";
}

open(my $in_fh, $temp2bed) or die $!;
open(my $bed_fh, ">$bed") or die $!;
while(<$in_fh>){
	# blockStart positions should be calculated relative to chromStart.
	# the first blockStart value must be 0, so that the first block begins at chromStart
	my($chrom, $start, $end, $name, $score, $strand, $thickStart, $thickEnd, $rgb, $blockCt, $blockSize, $blockStarts) = split/\t/, $_;
	my $newname = $newnames{$chrom}{$strand}{$start};
	print $bed_fh join("\t", ($chrom, $start, $end, $newname, $score, $strand, $thickStart, $thickEnd, $rgb, $blockCt, $blockSize, $blockStarts));
}
close $in_fh;
close $bed_fh;

#tidy up
system("rm $temp1bed") == 0 or die $!;
system("rm $temp2bed") == 0 or die $!;
