library(tidyverse)
library(TxDb.Hsapiens.UCSC.hg19.knownGene,verbose = FALSE)
library(Rsamtools)
library(BiocParallel)
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
seqlevels(txdb) <- sub("^chr", "", seqlevels(txdb))
register(SerialParam())
chip_bams <- file.path('/scratch/work/courses/BI7653/hw11.2025/ngs.hw11',
                       c('SRR7207011/SRR7207011.sorted.q20.bam','SRR7207017/SRR7207017.sorted.q20.bam'))
control_bam <- '/scratch/work/courses/BI7653/hw11.2025/ngs.hw11/SRR7207089/SRR7207089.sorted.q20.bam'
peaks <- file.path('/scratch/work/courses/BI7653/hw11.2025/ngs.hw11',
                   c('SRR7207011_macs3_peaks.BED_peaks.narrowPeak','SRR7207017_macs3_peaks.BED_peaks.narrowPeak'))

#create a tibble (data.frame) with the 
samples.tbl_df <- tibble(SampleID = c('SRR7207011','SRR7207017'),
                         Tissue = rep('prostate',2),
                         Factor = rep('AR',2),
                         Replicate = 1:2,
                         bamReads = chip_bams,
                         ControlID = c('SRR7207089','SRR7207089'),
                         Peaks = peaks,
                         PeakCaller = rep('narrow',2),
                         bamControl = c(control_bam,control_bam))
#view
samples.tbl_df

AR.ChIPQCexperiment <- ChIPQC(experiment = samples.tbl_df,
                              annotation="hg19", workers = 1)
QCmetrics(AR.ChIPQCexperiment)
ChIPQCreport(AR.ChIPQCexperiment)