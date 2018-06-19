#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 3){
	die "$0 <tx_overlap.txt> <bin_size> <max_bin>\n";
}
my $tx_overlap = $ARGV[0];
my $bin_size = $ARGV[1];
my $max_bin = $ARGV[2];

my %read_sum_by_tx_len;
open(my $tx_overlap_fh, "$tx_overlap") or die $!;
while(<$tx_overlap_fh>){
	my($gene_name, $transcript_length, $exon_ct, $overlapping_read_count, $full_cov_ct, $full_cov_pct, $first_last_count, $first_last_pct) = split/\t/, $_;
	my$tx_len_bin = int($transcript_length/$bin_size+1)*$bin_size; 
	if($tx_len_bin > $max_bin){
		$tx_len_bin = $max_bin;
	}
	#print "length = $transcript_length, bin = $tx_len_bin\n";
	$read_sum_by_tx_len{$tx_len_bin}{overlapping_read_count} += $overlapping_read_count;
	$read_sum_by_tx_len{$tx_len_bin}{full_cov_count} += $full_cov_ct;
}
for (my $bin = $bin_size; $bin <= $max_bin; $bin += $bin_size){
	$read_sum_by_tx_len{$bin}{overlapping_read_count}+=0;
	$read_sum_by_tx_len{$bin}{full_cov_count}+=0;
	my $total_reads = $read_sum_by_tx_len{$bin}{overlapping_read_count};
	my $fl_reads = $read_sum_by_tx_len{$bin}{full_cov_count};
	my $frac_full = 0;
	if($total_reads > 0){
		$frac_full = sprintf("%.1f",(($fl_reads/$total_reads)*100));
	}
	print "$bin\t$total_reads\t$fl_reads\t$frac_full\%\n";
}


