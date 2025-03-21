#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=task1_nfcore
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCH --mail-user=tt2405@nyu.edu

module purge
module load nextflow/24.10.4

nextflow run nf-core/rnaseq -r 3.14.0 \
	--input /scratch/work/courses/BI7653/hw8.2025/rnaseq_samplesheet.csv \
	--outdir res \
	--fasta /scratch/work/courses/BI7653/hw8.2025/hg38/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz \
	--gtf /scratch/work/courses/BI7653/hw8.2025/hg38/Homo_sapiens.GRCh38.111.gtf.gz \
	--extra_salmon_quant_args \"--gcBias\" \
	--save_reference \
	-profile nyu_hpc \
	--account=pr_284_general \
	-c /scratch/work/courses/BI7653/hw8.2025/rnaseq.config \
	-params-file /scratch/work/courses/BI7653/hw8.2025/rnaseq.json # note: we pass the JSON or YAML file in to nextflow here


echo _ESTATUS_ [ Nextflow ]: $?

echo "Job completed on: $(date)"
