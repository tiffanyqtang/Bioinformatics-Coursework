#!/bin/bash

#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --time=24:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=task3_bedcov
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCH --mail-user=tt2405@nyu.edu

module purge
module load samtools/intel/1.20

samtools bedcov /scratch/work/courses/BI7653/hw6.2025/chromosome_1.500bp_intervals.bed /scratch/work/courses/BI7653/hw6.2025/CR2342.bam /scratch/work/courses/BI7653/hw6.2025/CR407.bam > task3_output

echo $(date)
