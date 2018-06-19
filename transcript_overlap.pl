#!/usr/bin/env perl
use warnings;
use strict;

unless(@ARGV == 2){
	die "$0 <genes.bed12> <long_read.bam>\n";
}
my $genes_bed = $ARGV[0];
my $reads_bam = $ARGV[1];

my %transcript_stats;
open(my $overlap_fh, "intersectBed -a $genes_bed -b $reads_bam -split -wao |");
while(<$overlap_fh>){
	$_ =~ s/\n//;
	#bed12
	my($chr, $gene_start, $gene_end, $gene_name, $gene_score, $gene_strand, $cds_start, $cds_end, $color, $exon_ct, $exon_lengths, $exon_starts, $read_chr, $read_start, $read_end, $read_name, $read_score, $read_strand, $overlap) = split/\t/, $_;
	my $gene_length = $gene_end - $gene_start;
	my @exon_starts = split/\,/,$exon_starts;
	my @exon_lengths = split/\,/,$exon_lengths;
	my $first_exon = $gene_start+$exon_lengths[0];
	my $last_exon = $gene_start+$exon_starts[-1];

	#record basic stats about transcript
	my $transcript_length;
	map { $transcript_length += $_ } @exon_lengths;
	$transcript_stats{$gene_name}{length} = $transcript_length;
	$transcript_stats{$gene_name}{exons} = $exon_ct;

	#Account for transcripts with no overlapping read
	#print "$_\n";
	#print "overlap = #$overlap#\n";
	unless($overlap =~ /\d/){
		$transcript_stats{$gene_name}{reads}+=0;
		$transcript_stats{$gene_name}{covered}+=0;
		$transcript_stats{$gene_name}{firstToLast}+=0;
		next;
	}
	
	#does the read alignment extend from first to last exon?
	my $first_last = 0;
	if(($read_start < $first_exon) && ($read_end > $last_exon)){
		$first_last++;
	}

	#does the read alignment cover > 90% of the transcript length 
	my $percent_overlap = sprintf("%.1f",(($overlap/$transcript_length)*100));
	my $full_coverage = 0;
	if($percent_overlap > 90){
		$full_coverage++;
	}
	$transcript_stats{$gene_name}{reads}++;
	$transcript_stats{$gene_name}{covered}+=$full_coverage;
	$transcript_stats{$gene_name}{firstToLast}+=$first_last;
	#print "$gene_name\t$gene_length\t$transcript_length\t$read_name\t$overlap\t$percent_overlap\%\t$first_last\n";
}
foreach my$gene_name(keys %transcript_stats){
	my $transcript_length = $transcript_stats{$gene_name}{length};
	my $exon_ct = $transcript_stats{$gene_name}{exons};
	my $overlapping_read_count = $transcript_stats{$gene_name}{reads};
	my $full_cov_ct = $transcript_stats{$gene_name}{covered};
	my $first_last_count = $transcript_stats{$gene_name}{firstToLast};

	my $full_cov_pct;
       	if($overlapping_read_count == 0){
		$full_cov_pct = 0;
	}else{	
		$full_cov_pct = sprintf("%.1f",(($full_cov_ct/$overlapping_read_count)*100));
	}

	my $first_last_pct;
       	if($overlapping_read_count == 0){
		$first_last_pct = 0;
	}else{	
		$first_last_pct = sprintf("%.1f",(($first_last_count/$overlapping_read_count)*100));
	}
	print "$gene_name\t$transcript_length\t$exon_ct\t$overlapping_read_count\t$full_cov_ct\t$full_cov_pct\%\t$first_last_count\t$first_last_pct\%\n";
}


