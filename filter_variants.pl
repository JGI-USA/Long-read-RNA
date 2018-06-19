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
		print $_."\n";
		next;
	}
	if($_ =~ /\.\/\./){next;}

	my($chr, $pos, $id, $ref, $alt, $qual, $filter, $info, $format, $ont_r) = split/\t/, $_; 

	my @alt = split /\,/, $alt;
	
	my ($ont_r_g, $ont_r_af, $ont_r_sum) = parse_vars($ont_r); 
	my @ont_r_af = @$ont_r_af;

	#check at least five reads per sample
	unless($ont_r_sum > 10){ next;}

	for(my $v = 0; $v < scalar(@alt); $v++){

		#exclude indel
		unless(length($alt[$v]) == length ($ref)){
			next;
		}

		#clean up the variant
		my @ref_seq = split//,$ref;
		my @alt_seq = split//,$alt[$v];
		while($alt_seq[-1] eq $ref_seq[-1]){
			pop(@alt_seq);
			pop(@ref_seq);
		}my $ref_clean = join("",@ref_seq);
		my $alt_clean = join("",@alt_seq);

		
		my $ont_r_ct = $ont_r_af[$v+1];
		my $ont_r_freq = $ont_r_ct/$ont_r_sum;

		my $class;
		if($ont_r_freq > 0.9){
			$class = "hi_freq_rna";
		}else{
			$class = "other";
		}
		print 	"$chr\t$pos\t$id\t$ref_clean\t$alt_clean\t$qual\t$filter\t$info\t$format\t",
			"$ont_r_ct\/$ont_r_sum\t",
			"$class\n";
	}
}

sub parse_vars{
	my($var) = @_;
	my($g, $af) = split/\:/, $var;
	my(@af) = split/\,/, $af;
	my$tot = 0;
	map {$tot += $_} @af;
	return($g, \@af, $tot);
}
