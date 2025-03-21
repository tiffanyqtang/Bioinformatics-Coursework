#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=slurm_template
#SBATCH --account=pr_284_general
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tt2405@nyu.edu

module purge

module load fastp/intel/0.20.1
fastp -i /scratch/work/courses/BI7653/hw2.2025/ERR156634_1.filt.fastq.gz -I /scratch/work/courses/BI7653/hw2.2025/ERR156634_2.filt.fastq.gz -o out.R1.fq.gz -O out.R2.fq.gz --length_required 76 --n_base_limit 50 --detect_adapter_for_pe
echo command exit status: $?
echo script completed: $(date)

