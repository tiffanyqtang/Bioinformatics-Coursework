#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=2:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=assignment10_task4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=tt2405@nyu.edu
#SBATCH --account=pr_284_general

module purge
module load macs3/intel/3.0.0a5

CHIP1="SRR7207011/SRR7207011.sorted.q20.bam"
CHIP2="SRR7207017/SRR7207017.sorted.q20.bam"
INPUT="SRR7207089/SRR7207089.sorted.q20.bam"

# Peak calling for SRR7207011

macs3 callpeak \
  -t $CHIP1 \
  -c $INPUT \
  -f BAM \
  -g hs \
  -n SRR7207011_AR_ChIP \ # androgen receptor ChIP sample
  -B \
  -q 0.05 \
  --keep-dup auto


# Peak calling for SRR7207017

macs3 callpeak \
  -t $CHIP2 \
  -c $INPUT \
  -f BAM \
  -g hs \
  -n SRR7207017_AR_ChIP \
  -B \
  -q 0.05 \
  --keep-dup auto

echo "Job complete $(date)"
