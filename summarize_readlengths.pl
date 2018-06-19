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

my %rlsummary;
my %names;
foreach my $sample(@samples){
	my $rl = "$sample/$sample.readlength.txt";
	summarize_readlengths($sample, $rl);
	my $tl = "$sample/PrimaryTranscripts.readlength.txt";
	summarize_readlengths("primary transcripts", $tl);
}

my @names = sort keys %names;
print "\t".join("\t",@names)."\n";
foreach my $rl (sort { $a <=> $b } keys %rlsummary){
	print "$rl\t";
	foreach my $name(@names){
		$rlsummary{$rl}{$name}+=0;
		print "$rlsummary{$rl}{$name}\t";
	}print "\n";
}

sub summarize_readlengths {
	my($name, $rl) = @_;
	$names{$name}++;
	open(my $rl_fh, $rl) or die $!;
	while(<$rl_fh>){
		if($_ =~ /^#/){next;}
		$_ =~ s/\n//;
		my($len, $reads, $pct_reads, $cum_reads, $cum_pct_reads, $bases, $pct_bases, $cum_bases, $cum_pct_bases) = split/\t/, $_;
		$pct_reads =~ s/\%//;
		$rlsummary{$len}{$name} = $pct_reads;
	}
}


			
