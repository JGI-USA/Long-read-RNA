#!/bin/bash -l
#SBATCH --ntasks=2 #3 tasks total
#SBATCH -N 2 #Use 3 nodes (one per task)
#SBATCH -c 64 #number of cpus required per task = all available on haswell node = 64 threads (due to hyperthreading)
#SBATCH -t 12:00:00  #Set 12 hour time limit
#SBATCH -C haswell   #Use Haswell nodes
#SBATCH --qos=jgi #Use JGI allocation
#SBATCH -A gentechp #Charge to gentech
#SBATCH --exclusive #Charge to gentech

SCRIPT=/global/u2/m/mjblow/user_support_projects/Long_Read_RNA/scripts/map_reads_cori.sh
PROJECT=Arabidopsis_lyrata_SeqTech_USA-79
GENOME=/global/dna/projectdirs/RD/DNA_base_modifications/genomes/Alyrata/Alyrata_384_v1.fa
TX_FA=/global/homes/m/mjblow/user_support_projects/genomes/Alyrata/Alyrata_384_v2.1.cds_primaryTranscriptOnly.fa
TX_GFF=/global/dna/projectdirs/RD/DNA_base_modifications/genomes/Alyrata/Alyrata_384_v2.1.gene_exons.sorted.gff3
TX_BED=/global/dna/projectdirs/RD/DNA_base_modifications/genomes/Alyrata/Alyrata_384_v2.1.gene_exons.sorted.bed

#X0141 - OLD base caller
srun -N1 -n1 -c 64 --exclusive ${SCRIPT} ${PROJECT} ONT_RNA_X0141_ALB2-0-2 ${GENOME} ${TX_FA} ${TX_GFF}	${TX_BED} /global/dna/projectdirs/RD/Adv-Seq/www/OxfordNanoPore-AnalysisReports/X0141-albacore-2.0.2/data/nanopore04_20171027_FAH26018_MN18619_sequencing_run_171027_X0141_001-combined.pass-1D.fastq.gz	/global/dna/projectdirs/RD/Adv-Seq/www/OxfordNanoPore-AnalysisReports/X0141-albacore-2.0.2/data/nanopore04_20171027_FAH26018_MN18619_sequencing_run_171027_X0141_001-combined.fail-fwd.fastq.gz &

#X0141 - New Basecaller - albacore2.1 #PASS + FAIL READS
srun -N1 -n1 -c 64 --exclusive ${SCRIPT} ${PROJECT} ONT_RNA_X0141_ALB2-1 ${GENOME} ${TX_FA} ${TX_GFF} ${TX_BED}	/global/dna/projectdirs/RD/Adv-Seq/www/OxfordNanoPore-AnalysisReports/X0141/data/nanopore04_20171027_FAH26018_MN18619_sequencing_run_171027_X0141_001-combined.pass-1D.fastq.gz	/global/dna/projectdirs/RD/Adv-Seq/www/OxfordNanoPore-AnalysisReports/X0141/data/nanopore04_20171027_FAH26018_MN18619_sequencing_run_171027_X0141_001-combined.fail-fwd.fastq.gz &

wait
