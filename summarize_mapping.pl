#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 1){
	die "$0 <list_of_sample_dirs>\n";
}

my @samples;
open(my $samples_fh, $ARGV[0]) or die $!;
while(<$samples_fh>){
	$_ =~ s/\n//;
	push(@samples, $_);
}

foreach my $sample(@samples){
	my $bam = "$sample/$sample.minimap2.bam";
	open(my $bam_fh, "samtools flagstat $bam |") or die $!;
	while(<$bam_fh>){
		$_ =~ s/\n//;
		my($len, $reads, $pct_reads, $cum_reads, $cum_pct_reads, $bases, $pct_bases, $cum_bases, $cum_pct_bases) = split/\t/, $_;
		$pct_reads =~ s/\%//;
		$rlsummary{$len}{$name} = $pct_reads;
	}
}


			
