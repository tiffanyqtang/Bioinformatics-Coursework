#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=fastp_array
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tt2405@nyu.edu
#SBATCH --array=1-8
#SBATCH --account=pr_284_general

module purge

# Path to 3-column (tab-delimited) table with sample name, fastq 1 file name, and fastq 2 file name

table=/scratch/work/courses/BI7653/hw2.2025/week2_fastqs.txt


# Define sample, fq1 and fq2 variables for current array index
# note: SLURM_ARRAY_TASK_ID environmental variable will contain a single value corresponding to the current array index

line="$(head -n $SLURM_ARRAY_TASK_ID $table | tail -n 1)"
sample="$(printf "%s" "${line}" | cut -f1)"
fq1="$(printf "%s" "${line}" | cut -f2)"
fq2="$(printf "%s" "${line}" | cut -f3)"

# Print to standard out the array index and the sample name (this will show up in each of the slurm*out files created by the job)

echo Processing array index: $SLURM_ARRAY_TASK_ID sample: $sample


# Make a directory for the sample and cd to it

mkdir $sample
cd $sample


# define output filenames. This will add "fP" (=forward paired) and "rP" (=reverse paired) to output file names

fq1_fastp=$(basename $fq1 .fastq.gz).fP.fastq.gz
fq2_fastp=$(basename $fq2 .fastq.gz).rP.fastq.gz


# Load the fastp software module

module load fastp/intel/0.20.1

# Define directory where fastqs are located

fqdir=/scratch/work/courses/BI7653/hw2.2025

# Run fastp on sample fastqs

# note: we discard read pairs where either read is < 76 bp after trimming
# note: we use "*fastp.json" extension to ensure compatibility with MultiQC
 
fastp -i $fqdir/$fq1 \
-I $fqdir/$fq2 \
-o $fq1_fastp \
-O $fq2_fastp \
--length_required 76 \
--detect_adapter_for_pe \
--n_base_limit 50 \
--html $sample.fastp.html \
--json $sample.fastp.json

# Print the exit status of the fastp command and the time the script ended to standard out

echo _ESTATUS_ [ fastp for $sample ]: $?


# Purge fastp and load fastqc module

module purge
module load fastqc/0.11.9

# Run fastqc

fastqc $fq1_fastp $fq2_fastp

echo _ESTATUS_ [ fastqc for $sample ]: $?

echo _END_ [ fastp for $sample ]: $(date)
