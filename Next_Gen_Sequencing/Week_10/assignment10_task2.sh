#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=4:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=assignment10_task2
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCH --mail-user=tt2405@nyu.edu

module purge
module load fastp/intel/0.20.1

for sra in SRR7207011 SRR7207017 SRR7207089
do
echo "Processing $sra"
fastp -i ${sra}/${sra}.fastq -o ${sra}/${sra}.trimmed.fastq --length_required 50
done

echo "Job Complete $(date)"
