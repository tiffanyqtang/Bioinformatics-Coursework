library(ChIPseeker)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
library(clusterProfiler)

files <- getSampleFiles()
cbx6.bed <- files[[4]]
peak.GRanges <- readPeakFile(cbx6.bed) # create a GRAanges object with peak intervals and heights

covplot(peak.GRanges, weightCol="V5")

peakHeatmap(cbx6.bed, TxDb = TxDb.Hsapiens.UCSC.hg19.knownGene, type = "start_site", by = "gene", upstream = 2000, downstream = 2000, nbin = 400)

plotPeakProf2(peak = files[[4]],
              upstream = 2000,
              downstream = 2000,
              by = "gene",
              type = "start_site",
              TxDb = txdb,
              nbin = 400)