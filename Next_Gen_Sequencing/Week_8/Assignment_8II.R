library(tximport)
library(DESeq2)
library(tidyverse)
library(apeglm)
library(ggplot2)

# Create info for metadata and file paths
patient_ids <- c('PG038','PG108','PG123','PG136')
sample_names <- c(paste(patient_ids,'_N',sep=''),paste(patient_ids,'_T',sep=''))
sample_condition <- c(rep('normal',4),rep('tumor',4))

files <- file.path("C:/Users/tiffa/OneDrive/Desktop/Masters in Bioinformatics/NGS/Week 8/salmon_results", sample_names, "quant.sf")
names(files) <- sample_names
tx2gene <- read.table("C:/Users/tiffa/OneDrive/Desktop/Masters in Bioinformatics/NGS/Week 8/tx2gene.tsv", header=F, sep="\t")

txi <- tximport(files, type="salmon", tx2gene=tx2gene) # The txi variable is a simple list object containing gene counts and other info

class(txi)
names(txi)

txi[['counts']] %>%
  head()

#Create metadata.df data.frame
metadata.df <- data.frame(sample = factor(sample_names),
                          patient = factor( c(patient_ids,patient_ids)),
                          condition = factor(sample_condition,levels = c('normal','tumor')) )

# set row names attribute of metadata.df
row.names(metadata.df) <- sample_names
head(metadata.df)

# Use tximport to import Salmon quant.sf files to convert transcript-level TPMs, to gene-level counts and specify design formula
dds <- DESeqDataSetFromTximport(txi,
                                colData = metadata.df,
                                design = ~ patient + condition)

keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
dds <- DESeq(dds) 

res <- results(dds, contrast = c('condition','tumor','normal'),alpha = 0.05)

# View
res

res.lfcShrink <- lfcShrink(dds, coef="condition_tumor_vs_normal", type="apeglm")

# Convert to data frame and filter for FDR ≤ 5%
res.lfcShrink %>%
  as.data.frame() %>%
  rownames_to_column(var = "GeneID") %>%
  as_tibble() %>%
  filter(padj <= 0.05) %>%
  summarise(Num_Sig_Genes = n()) # Count significant genes (Q1.1)

# Filter for significant and upregulated genes (log2FC ≥ 1)
res.lfcShrink %>%
  as.data.frame() %>%
  rownames_to_column(var = "GeneID") %>%
  as_tibble() %>%
  filter(padj <= 0.05, log2FoldChange >= 1) %>%
  summarise(Num_Upregulated_Genes = n()) # Count upregulated significant genes (Q1.2)

# Sort by FDR (padj)
sorted_res <- res.lfcShrink %>%
  as.data.frame() %>%
  rownames_to_column(var = "GeneID") %>%
  as_tibble() %>%
  arrange(padj)  # Sort by padj in ascending order

# Get the most significant gene (smallest FDR)
top_gene <- sorted_res$GeneID[1]
cat("Most significant gene:", top_gene, "\n")

# Plot normalized counts for this gene
plotCounts(dds, gene = top_gene, intgroup = "condition", returnData = FALSE)

plotMA(res)

resultsNames(dds) # Here we can see the coefficients including 'condition_tumor_vs_normal'

# note: by providing res as an argument we ensure that alpha = 0.05 is also the basis for p-values reported by lfcShrink.
res.lfcShrink <- lfcShrink(dds, 
                           res = res,
                           coef = 'condition_tumor_vs_normal',
                           type = 'apeglm')
# View
res.lfcShrink

plotMA(res.lfcShrink)

res.lfcShrink %>% 
  as_tibble() %>%
  summarise(padj_NA = sum(is.na(padj)), # summarise collapses output to a single row with new columns with summaries of the data
            padj_notNA = sum(!is.na(padj)))

plot(metadata(res.lfcShrink)$filterNumRej, 
     type="b", ylab="number of rejections",
     xlab="quantiles of filter")
lines(metadata(res)$lo.fit, col="red")
abline(v=metadata(res)$filterTheta)

metadata(res.lfcShrink)$filterThreshold

plotDispEsts(dds)
