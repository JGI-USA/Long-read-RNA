#!/usr/bin/env perl
use warnings;
use strict;
use File::Spec;
use File::Spec::Functions;

unless(@ARGV == 7){
	die "$0 <outpath> <name> <genome_fasta> <genes_fasta> <genes_gff> <reads.fastq.gz,more_reads.fastq.gz,...> <threads>\n";
}
my $outpath = $ARGV[0]; # e.g. Arabidopsis_SeqTech_USA-70B
my $name = $ARGV[1]; # e.g. ONT_RNA_X0143_ALB2-1
my $genome_fasta = $ARGV[2]; # e.g. Athaliana_167_TAIR9.fa
my $genes_fasta = $ARGV[3]; # e.g. Athaliana_167_TAIR10.cds_primaryTranscriptOnly.fa
my $genes_gff= $ARGV[4]; # e.g. Athaliana_167_TAIR10.gene_exons.gff3
my $reads = $ARGV[5]; # e.g. nanopore02_jgi_psf_org_20170608_FNFAH04643_MN18617_sequencing_run_170608_1002001975_001-combined.pass-1D.fastq.gz
my $threads = $ARGV[6]; # e.g. nanopore02_jgi_psf_org_20170608_FNFAH04643_MN18617_sequencing_run_170608_1002001975_001-combined.pass-1D.fastq.gz

#Make output directory
$outpath = File::Spec->rel2abs($outpath);
my $results = File::Spec->rel2abs("$outpath/$name");
`mkdir -p $results`;
my $log = "$results/$name.log";


#link to genome fasta
my ($genome_volume,$genome_fasta_dir,$genome_fasta_name) = File::Spec->splitpath(File::Spec->rel2abs($genome_fasta)) ;
my $genome_fasta_link = "$results/$genome_fasta_name";
`ln -s $genome_fasta_dir/$genome_fasta_name $genome_fasta_link`; 

#link to gene fasta
my ($genes_volume,$genes_fasta_dir,$genes_fasta_name) = File::Spec->splitpath(File::Spec->rel2abs($genes_fasta)) ;
my $genes_fasta_link = "$results/$genes_fasta_name";
`ln -s $genes_fasta_dir/$genes_fasta_name $genes_fasta_link`; 

#link to gene gff 
my ($gff_volume,$gff_dir,$gff_name) = File::Spec->splitpath(File::Spec->rel2abs($genes_gff)) ;
my $gff_link = "$results/$gff_name";
`ln -s $gff_dir/$gff_name $gff_link`; 

#combine reads
my @fastqs = split/,/, $reads;
my @abs_fastqs;
foreach my $fastq(@fastqs){
	my ($reads_volume,$reads_dir,$reads_name) = File::Spec->splitpath(File::Spec->rel2abs($fastq)) ;
	my $abs_fastq = "$reads_dir/$reads_name";
	push(@abs_fastqs, $abs_fastq);
}
my $reads_link = "$results/$name.fastq.gz";
my $combine_fastqs = "cat ".join(" ",@abs_fastqs)." > $reads_link";
`$combine_fastqs`;

#convert U to T in fastq file (required by samtools)
`UtoT_fastq.pl $reads_link`;

#prep gene files
`prep_genes.pl $gff_link`;

my $prefix = $gff_link;
$prefix =~ s/\.gff3//;
my $bed = "$prefix.bed";
my $gtf = "$prefix.gtf";

#get readlength distributions of inputs
`readlength.sh in=$genes_fasta_link bin=100 max=50000 nzo=f out=$results/PrimaryTranscripts.readlength.txt 2>>$log`;
`readlength.sh bin=100 nzo=f max=50000 in=$reads_link out=$results/$name.readlength.txt 2>>$log`;

#map reads using minimap2
`minimap2 -x splice -a -t $threads $genome_fasta_link $reads_link > $results/$name.minimap2.sam 2>>$log`;


#Convert to bam and index
`samtools view -bhS $results/$name.minimap2.sam | samtools sort - -o $results/$name.minimap2.bam 2>>$log`;
`samtools index $results/$name.minimap2.bam 2>>$log`;

#Mapping stats
`mapstat.sh $results/$name.minimap2.sam > $results/$name.mapstats.txt 2>>$log`;
`samtools flagstat $results/$name.minimap2.bam > $results/$name.flagstat.txt 2>>$log`;

#Intersect with gene annotations
`transcript_overlap.pl $bed $results/$name.minimap2.bam > $results/$name.tx_overlap.txt 2>>$log`;

#Summarize first-to-last-exon reads by tx exon count
`first_to_last_exon_reads.pl $results/$name.tx_overlap.txt > $results/$name.exon_cov.txt 2>>$log`;

#summarzie >90% tx coverage by tx_length
`full_transcript_reads.pl $results/$name.tx_overlap.txt 500 10000 > $results/$name.tx_cov.txt 2>>$log`;

#compare with annotated introns
`intron-eval.sh $gtf $results/$name.minimap2.sam > $results/$name.intron_eval.txt 2>>$log`;

#run variant detection analysis
`htsbox pileup -s 5 -q 10 -vcf $genome_fasta_link $results/$name.minimap2.bam > $results/$name.minimap2.vcf 2>>$log`;

#pull out indels
`extract_indels.pl  $results/$name.minimap2.vcf | sort -k 1,1 -k2,2n > $results/$name.minimap2.indels.bed 2>>$log`;

#keep mismatches that are >5bp from nearest indel
`intersectBed -header -v -a $results/$name.minimap2.vcf -b $results/$name.minimap2.indels.bed > $results/$name.minimap2.no-indels.vcf 2>>$log`;

#filter for variants with >10 reads and allele frequency >90%
`filter_variants.pl $results/$name.minimap2.no-indels.vcf  > $results/$name.filtered_variants.vcf 2>>$log`;

#Intersect with gene annotations
`intersectBed -wb -a $results/$name.filtered_variants.vcf -b $gff_link | grep exon | cut -f 1-11,18,20 |  uniq > $results/$name.filtered_variants.annotated.vcf 2>>$log`;

#Reorient variants with respect to transcribed strand
`fix_strandedness.pl $results/$name.filtered_variants.annotated.vcf > $results/$name.filtered_variants.annotated.vcf.stranded.txt 2>>$log`;

#Extract coordinates of variants +- 3bp
`awk '{print \$1"\t"\$2-3"\t"\$3+3"\t"\$4"\t"\$5"\t"\$6}' $results/$name.filtered_variants.annotated.vcf.stranded.txt > $results/$name.filtered_variants.local_context.bed 2>>$log`;

#Get flanking sequence contexts
`fastaFromBed -fi $genome_fasta_link -bed $results/$name.filtered_variants.local_context.bed -s -tab -fo $results/$name.filtered_variants.local_context.seq 2>>$log`;

#Reannotate variant files with flanking sequence contexts
`add_seq_context.pl $results/$name.filtered_variants.annotated.vcf.stranded.txt $results/$name.filtered_variants.local_context.seq > $results/$name.filtered_variants.annotated.vcf.stranded.seq.txt 2>>$log`;

