#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --mem=14GB
#SBATCH --job-name=align_task1
#SBATCH --mail-type=FAIL
#SBATCH --account=pr_284_general
#SBATCH --mail-user=tt2405@nyu.edu

module purge
module load star/intel/2.7.11a

sample=PDAC253

STAR \
	--genomeDir /scratch/work/courses/BI7653/hw7.2025/STAR.genome \
	--runThreadN ${SLURM_CPUS_PER_TASK} \
	--readFilesIn /scratch/work/courses/BI7653/hw7.2025/fastqs_processed/PDAC253_1PE.fP.fastq.gz /scratch/work/courses/BI7653/hw7.2025/fastqs_processed/PDAC253_2PE.rP.fastq.gz \
	--readFilesCommand zcat \
	--limitBAMsortRAM 12000000000 \
	--outSAMtype BAM SortedByCoordinate \
	--outFileNamePrefix $sample \
	--outTmpDir ${SLURM_JOBTMP}/${SLURM_JOBID} 

echo _ESTATUS_ [ STAR ]: $?

module purge
module load samtools/intel/1.20
samtools index ${sample}Aligned.sortedByCoord.out.bam

echo "Job completed on: $(date)"
