#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 3){
	die "$0 <tx_overlap.txt> <min exon count> <all|full_length|first_last>\n";
}
my $tx_overlap = $ARGV[0];
my $min_exons = $ARGV[1];
my $mode = $ARGV[2];

my %overlapping_reads;
open(my $tx_overlap_fh, "$tx_overlap") or die $!;
while(<$tx_overlap_fh>){
	my($gene_name, $transcript_length, $exon_ct, $overlapping_read_count, $full_cov_ct, $full_cov_pct, $first_last_count, $first_last_pct) = split/\t/, $_;
	unless($exon_ct >= $min_exons){next};
	my $ct = 0;
	if($mode eq "all"){
		$ct = $overlapping_read_count;
	}elsif($mode eq "full_length"){
		$ct = $first_last_count;
	}elsif($mode eq "first_last"){
		$ct = "$first_last_count";
	}else{
		die "unrecognized: $mode\n";
	}if($ct > 10){
		$ct = "10+";
	}$overlapping_reads{$ct}++;
}

my @ct = (0,1,2,3,4,5,6,7,8,9,10,"10+"); 
foreach my $ct (@ct){
	$overlapping_reads{$ct}+=0;
	print "$ct\t$overlapping_reads{$ct}\n";
}


