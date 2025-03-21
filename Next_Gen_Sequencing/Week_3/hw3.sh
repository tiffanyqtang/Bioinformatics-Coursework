#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=16GB
#SBATCH --job-name=bwamem_array
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tt2405@nyu.edu
#SBATCH --account=pr_284_general
#SBATCH --array=1-4

module purge

# Please replace <your email> in the --mail-user directive above

# Define ref variable with path to normalized hg18 reference fasta
ref=/scratch/work/courses/BI7653/hw3.2025/hg38/Homo_sapiens.GRCh38.dna_sm.primary_assembly.normalized.fa

# Path to 3-column (tab-delimited) table with sample name, fastq 1 file name, and fastq 2 file name
table=/scratch/work/courses/BI7653/hw3.2025/week3_fastqs.txt
fqdir=/scratch/work/courses/BI7653/hw3.2025/fastqs.processed

# The following code defines sample, fq1 and fq2 variables for current array index
# note: SLURM_ARRAY_TASK_ID environmental variable will contain a single value corresponding to the current array index

line="$(head -n $SLURM_ARRAY_TASK_ID $table | tail -n 1)"
sample="$(printf "%s" "${line}" | cut -f1)"
fq1="$(printf "%s" "${line}" | cut -f2)"
fq2="$(printf "%s" "${line}" | cut -f3)"

# Print to standard out the array index and the sample name

echo Processing array index: $SLURM_ARRAY_TASK_ID sample: $sample

# Make a directory for the sample and cd to it

mkdir $sample
cd $sample

module load bwa/intel/0.7.17

# align reads to reference genome adding read groups to each alignment record
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
-R "@RG\tID:${sample}.id\tSM:${sample}\tPL:ILLUMINA\tLB:${sample}.lb" \
"${ref}" \
$fqdir/$fq1 \
$fqdir/$fq2 > $sample.sam

echo _ESTATUS_ [ bwa mem for $sample ]: $?

module purge
module load samtools/intel/1.14

# SAM->BAM conversion
samtools view -bh $sample.sam > $sample.bam

echo _ESTATUS_ [ SAM to BAM conversion ]: $?

module purge
module load picard/2.17.11

# coordinate sort BAM
java -Xmx15g -XX:ParallelGCThreads=1 -jar "${PICARD_JAR}" SortSam \
INPUT=$sample.bam \
OUTPUT=$sample.sorted.bam \
SORT_ORDER=coordinate \
TMP_DIR="${SLURM_JOBTMP}" \
MAX_RECORDS_IN_RAM=10000000 \
VALIDATION_STRINGENCY=LENIENT

echo _ESTATUS_ [ SortSam $sample ]: $?

module purge
module load samtools/intel/1.14

# index sorted BAM (BAM cannot be indexed if its not coordinate-sorted)
samtools index $sample.sorted.bam

echo _ESTATUS_ [ samtools index $sample ]: $?

echo _END_ [ hw3_bwamem.slurm for $sample ]: $(date)
