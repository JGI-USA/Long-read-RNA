#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 1){
	die "$0 <variants.vcf>\n";
}
my $vcf = $ARGV[0];
open(my $vcf_fh, $vcf) or die $!;
while(<$vcf_fh>){
	$_ =~ s/\n//;
	if($_ =~ /^#/){
		next;
	}
	my($chr, $pos, $id, $ref, $alt, $qual, $filter, $info, $format, $ont_r) = split/\t/, $_; 
	my @alt = split/\,/, $alt;
	my $indel = 0;
	foreach my $a(@alt){
		unless(length($ref)==length($a)){
			$indel++;
		}
	}
	if($indel > 0){
		print "$chr\t".($pos-5)."\t".($pos+5)."\n";
	}
}
