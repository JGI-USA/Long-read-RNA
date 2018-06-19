#!/usr/bin/env perl
use warnings;
use strict;

my $in = $ARGV[0];
unless(@ARGV == 1){
	die "$0 <fastq.gz>\n";
}

my $out = $in;
$out =~ s/\.gz/\.T.gz/;

open(my $in_fh, "gunzip -c $in |") or die $!;
open(my $out_fh, "| gzip > $out") or die $!;

while(my $h1 = <$in_fh>, my $s = <$in_fh>, my $h2 = <$in_fh>, my $q = <$in_fh>){
	$s =~ s/U/T/g;
	#print "$h1$s$h2$q";
	print $out_fh "$h1$s$h2$q";
}

system("mv $out $in") == 0 or die $!;

