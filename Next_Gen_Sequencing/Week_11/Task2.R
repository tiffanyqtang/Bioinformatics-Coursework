# Load pre-computed ChIPQC experiment

library(chipseq,verbose = FALSE)
library(ChIPQC,verbose = FALSE)
library(TxDb.Hsapiens.UCSC.hg38.knownGene,verbose = FALSE)

data(example_QCexperiment)
exampleExp

# review metrics output
QCmetrics(exampleExp)

# generate QC report 
ChIPQCreport(exampleExp)