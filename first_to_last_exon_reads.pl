#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 1){
	die "$0 <tx_overlap.txt>\n";
}
my $tx_overlap = $ARGV[0];

my %read_sum_by_exon_ct;
open(my $tx_overlap_fh, "$tx_overlap") or die $!;
while(<$tx_overlap_fh>){
	my($gene_name, $transcript_length, $exon_ct, $overlapping_read_count, $full_cov_ct, $full_cov_pct, $first_last_count, $first_last_pct) = split/\t/, $_;
	if($exon_ct > 6){$exon_ct = ">6";}
	$read_sum_by_exon_ct{$exon_ct}{overlapping_read_count} += $overlapping_read_count;
	$read_sum_by_exon_ct{$exon_ct}{first_last_count} += $first_last_count;
}
foreach my $exon_ct (sort keys %read_sum_by_exon_ct){
	my $total_reads = $read_sum_by_exon_ct{$exon_ct}{overlapping_read_count};
	my $fl_reads = $read_sum_by_exon_ct{$exon_ct}{first_last_count};
	my $frac_full = sprintf("%.1f",(($fl_reads/$total_reads)*100));
	print "$exon_ct\t$fl_reads\t$total_reads\t$frac_full\%\n";
}


