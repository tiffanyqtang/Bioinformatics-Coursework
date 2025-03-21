#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=run_sarek
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCH --mail-user=tt2405@nyu.edu
#SBATCH --account=pr_284_general

module purge
module load nextflow/23.04.1

nextflow run nf-core/sarek -r 3.4.0 \
--input ./samplesheet.csv \
--outdir res \
-profile nyu_hpc \
-c sarek_haplotypecaller.nyu_ngs.config

echo _ESTATUS_ [ nextflow run ]: $?
echo _END_ [ test_sarek.slurm ]: $(date)
