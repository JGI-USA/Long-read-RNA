#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 1){
	die "$0 <variants.filtered.annotated.vcf>\n";
}
my $vcf = $ARGV[0];
open(my $vcf_fh, $vcf) or die $!;
while(<$vcf_fh>){
	$_ =~ s/\n//;
	if($_ =~ /^#/){
		#print $_."\n";
		next;
	}

	my($chr, $pos, $id, $ref, $alt, $qual, $filter, $info, $format, $ont_r, $class, $strand, $gene) = split/\t/, $_; 

	if($strand eq "-"){
		$ref =~ tr/acgtACGT/tgcaTGCA/;
		$alt =~ tr/acgtACGT/tgcaTGCA/;
	}

	print "$chr\t".($pos-1)."\t$pos\t$ref>$alt\t$qual\t$strand\t$filter\t$info\t$format\t$ont_r\t$class\t$strand\t$gene\n";

}
