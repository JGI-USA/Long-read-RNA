#!/usr/bin env perl
use warnings;
use strict;

unless(@ARGV == 3){
	die "$0 <variants.filtered.annotated.vcf> <genes.gff> <cell_to_cell_genes.tab>\n";
}
my %gene_info;
my $gff = $ARGV[1];
open(my $gff_fh, $gff) or die $!;
while(<$gff_fh>){
	$_ =~ s/\n//;
	if($_ =~ /.*?Name=(.*?);.*Note=(.*?);.*locus_tag=(\w+);*.*$/){
		my $name = $1;
		my $note = $2;
		my $locus_tag = $3;
		#print "name=$name\nnote=$note\ntag=$locus_tag\n\n\n";	
		if(exists($gene_info{$locus_tag})){
			print "SEEN $locus_tag\n";
			next;
		}
		$gene_info{$locus_tag}{name}=$name;
		$gene_info{$locus_tag}{note}=$note;
		$gene_info{$locus_tag}{cell_to_cell}=0;
	}
}

my $c2c = $ARGV[2];
open(my $c2c_fh, $c2c) or die $!;
while(<$c2c_fh>){
	my @a = split/\t/, $_;
	my $locus_tag = $a[1];
	$gene_info{$locus_tag}{cell_to_cell}=1;
}

#foreach my $gene(keys %gene_info){
#	print "GENE=$gene\n";
#	print "name=$gene_info{$gene}{name}\n";
#	print "note=$gene_info{$gene}{note}\n";
#	print "cell_to_cell=$gene_info{$gene}{cell_to_cell}\n\n";
#}

my $vcf = $ARGV[0];
open(my $vcf_fh, $vcf) or die $!;
while(<$vcf_fh>){
	$_ =~ s/\n//;
	my ($chr, $start, $end, $var, $qual, $strand, $filter, $info, $format, $ont_r, $ont_c, $pb_c, $class, $gstrand, $ogene) = split/\t/, $_; 
	my ($gene, $crap) = split/\;/, $ogene;
	unless(exists($gene_info{$gene}{name})){
		$gene_info{$gene}{name} = "N/A";
	}unless(exists($gene_info{$gene}{note})){
		 $gene_info{$gene}{note} = "N/A";
	}unless(exists($gene_info{$gene}{cell_to_cell})){
		$gene_info{$gene}{cell_to_cell}=0;
	}

	 print join("\t", ($chr, $start, $end, $var, $qual, $strand, $filter, $info, $format, $ont_r, $ont_c, $pb_c, $class, $gstrand, $gene, $gene_info{$gene}{name}, $gene_info{$gene}{note}, $gene_info{$gene}{cell_to_cell}))."\n";	
}
