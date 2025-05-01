#!/bin/bash

#SBATCH  --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=4:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=assignment12_task1
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCH --mail-user=tt2405@nyu.edu

module purge
module load jellyfish/2.3.0

#Count the k-mers
jellyfish count -C -m 21 -s 1000000000 -t 10 chi2_combined.fq -o chi2_counts.jf

#Create the histogram
jellyfish histo -t 10 chi2_counts.jf > chi2_counts.histo

echo " Job completed on $(date)"
