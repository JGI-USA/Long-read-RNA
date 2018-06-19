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

my %variant_summary;
my %variant_sum;
my %seen;
foreach my $sample(@samples){
	#ONT_cDNA_X0137.filtered_variants.annotated.vcf.stranded.seq.txt
	my $variants = "$sample/$sample.filtered_variants.annotated.vcf.stranded.seq.txt";
	summarize_variants($sample, $variants);
}

print "\t".join("\t",@samples)."\n";
foreach my $var (sort keys %variant_summary){
	print "$var\t";
	foreach my $sample(@samples){
		$variant_summary{$var}{$sample}+=0;
		print "$variant_summary{$var}{$sample}\t";
	}print "\n";
}

sub summarize_variants {
	my($sample, $variants) = @_;
	open(my $var_fh, $variants) or die $!;
	while(<$var_fh>){
		$_ =~ s/\n//;
		if($_ =~ /^#/){next;}
		#Supercontig_2	4179574	4179575	A>T	13	+	.	.	GT:AD	13/13	hi_freq_rna	+	ID=exon_3681_5;Parent=mRNA_3681	TGCAGGA'
		my($chr, $start, $end, $var, $count, $strand, $bs, $be, $gt, $mod_v_unmod, $class, $gene_strand, $geneid, $context) = split/\t/, $_;
		unless($class eq "hi_freq_rna"){
			next;
		}
		if(exists($seen{$chr}{$start}{$var})){
			next;
		}else{
			$seen{$chr}{$start}{$var}++;
		}
		$variant_summary{$var}{$sample}++;
		$variant_sum{$sample}++;
	}
}


			
