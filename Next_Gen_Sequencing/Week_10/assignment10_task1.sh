#!/bin/bash

#SBATCH  --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=assignment10_task1
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCh --mail-user=tt2405@nyu.edu

module purge
module load sra-tools/3.1.0

for sra in SRR7207011 SRR7207017 SRR7207089
do
mkdir $sra
cd $sra 
fasterq-dump $sra --threads ${SLURM_CPUS_PER_TASK}
cd ..
done

echo "Job Completed on: $(date)"
