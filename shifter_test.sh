rm -rf TEST_RESULTS
shifter --image mjblow/longreadrna:v0.3 map_reads_generic.pl TEST_RESULTS ONT_RNA_X0143_ALB2-1 TEST_DATA/Athaliana_167_TAIR9.fa TEST_DATA/Athaliana_167_TAIR10.transcript.fa.gz TEST_DATA/Athaliana_167_TAIR10.gene_exons.gff3 $PWD/TEST_DATA/nanopore02_jgi_psf_org_20170809_FAH19668_MN18617_sequencing_run_170809_1002001975_001-combined.pass-1D.fastq.gz 4
