#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=28GB
#SBATCH --job-name=assignment10_task3
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tt2405@nyu.edu
#SBATCH --account=pr_284_general

module purge

# Human reference genome (hg38) fasta - index files are in the hg38 directory
ref=/scratch/work/courses/BI7653/hw3.2025/hg38/Homo_sapiens.GRCh38.dna_sm.primary_assembly.normalized.fa

for sra in SRR7207011 SRR7207017 SRR7207089
do

cd $sra
module load bwa/intel/0.7.17

# align reads with bwa mem

bwa mem -M -t $SLURM_CPUS_PER_TASK $ref ${sra}.trimmed.fastq > ${sra}.sam
echo _ESTATUS_ [ $sra bwa mem ]: $?

module purge # purge modules to prevent unexpected module collisions

module load samtools/intel/1.14

samtools view -bh ${sra}.sam > ${sra}.bam

module purge


module load picard/2.27.5

# coordinate-sort reads
# note: Picard is a java archive (a java app) that we launch with java <args to JRE> -jar <jar file> syntax
# note: the java runtime environment (JRE) can be configured to request a maximum memory (26 GB)
#       This is 2 GB less than we requested from the slurm scheduler to provide "memory overhead" for job execution

java -Xmx26g -jar $PICARD_JAR SortSam \
INPUT=${sra}.bam \
OUTPUT=${sra}.sorted.bam \
SORT_ORDER=coordinate \
TMP_DIR="${SLURM_JOBTMP}" \
MAX_RECORDS_IN_RAM=10000000 \
VALIDATION_STRINGENCY=LENIENT

echo _ESTATUS_ [ $sra coordinate-sort ]: $?

module purge


module load samtools/intel/1.14
samtools index ${sra}.sorted.bam



# remove reads with mapping quality < 20
samtools view -h -q 20 -b ${sra}.sorted.bam > ${sra}.sorted.q20.bam
echo _ESTATUS_ [ $sra samtools view -q 20 $sra ]: $?


# create index file (.bai) for final coordinate-sorted, minimum mapping quality 20 BAM
samtools index ${sra}.sorted.q20.bam

module purge

cd ..

done

echo "Job complete $(date)"
