#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 2){
	die "$0 <variants.filtered.annotated.vcf> <seq_context.tab>\n";
}
my %seq_context;
my $seq_context = $ARGV[1];
open(my $sc_fh, $seq_context) or die $!;
while(<$sc_fh>){
	$_ =~ s/\n//;
	my($reg, $seq) = split/\t/, $_;
	$seq_context{$reg} = $seq;
}

my $vcf = $ARGV[0];
open(my $vcf_fh, $vcf) or die $!;
while(<$vcf_fh>){
	$_ =~ s/\n//;
	if($_ =~ /^#/){
		next;
	}

	my ($chr, $start, $end, $var, $qual, $strand, $filter, $info, $format, $ont_r, $ont_c, $pb_c, $class, $gstrand, $gene) = split/\t/, $_; 
	my $reg = $chr.":".($start-3)."-".($end+3)."(".$strand.")";
	#print "reg = $reg\n";
	my $sc = $seq_context{$reg};
	print $_."\t$sc\n";
}
