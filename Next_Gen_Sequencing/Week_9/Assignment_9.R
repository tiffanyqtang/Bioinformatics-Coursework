library(tximport)
library(DESeq2)
library(tidyverse)

# Create info for metadata and file paths
patient_ids <- c('PG038','PG108','PG123','PG136')
sample_names <- c(paste(patient_ids,'_N',sep=''),paste(patient_ids,'_T',sep=''))
sample_condition <- c(rep('normal',4),rep('tumor',4))

files <- file.path('C:/Users/tiffa/OneDrive/Desktop/Masters in Bioinformatics/NGS/Week 9/salmon_results', sample_names, 'quant.sf')
names(files) <- sample_names
tx2gene <- read.table(file.path('C:/Users/tiffa/OneDrive/Desktop/Masters in Bioinformatics/NGS/Week 9/', 'tx2gene.tsv'), header = FALSE, sep = "\t")

txi <- tximport(files, type = "salmon", tx2gene = tx2gene)

#Create metadata.df data.frame
metadata.df <- data.frame(sample = factor(sample_names),
                          patient = factor( c(patient_ids,patient_ids)),
                          condition = factor(sample_condition,levels = c('normal','tumor')) )

# set row names attribute of metadata.df
row.names(metadata.df) <- sample_names

# Use tximport to import Salmon quant.sf files to convert transcript-level TPMs, to gene-level counts and specify design formula
dds <- DESeqDataSetFromTximport(txi,
                                colData = metadata.df,
                                design = ~ patient + condition)
# pre-filter low count genes
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

# run the DESeq2 wrapper
dds <- DESeq(dds)


res <- results(dds, contrast = c('condition','tumor','normal'),alpha = 0.05)

# note: by providing res as an argument we ensure that alpha = 0.05 is also the basis for p-values reported by lfcShrink.
res.lfcShrink <- lfcShrink(dds, 
                           res = res,
                           coef = 'condition_tumor_vs_normal',
                           type = 'apeglm')
res.lfcShrink

mcols(res.lfcShrink)$description

res.lfcShrink %>%
  as.data.frame() %>% # coerce to data.frame first to preserve rownames attribute
  rownames_to_column(var = "GeneID") %>%
  as_tibble()

plotMA(res.lfcShrink)

# to make a histogram
res.lfcShrink %>%
  as_tibble() %>% # coerce to tibble
  ggplot(aes(pvalue)) + 
  geom_histogram(fill="light blue",color='black',bins = 40)

sum(!is.na(res.lfcShrink$padj)) *.05

#Applying Bonferroni correction
m <- sum(!is.na(res.lfcShrink$pvalue))
alpha <- 0.05
bonferroni_threshold <- alpha / m
sum(res.lfcShrink$pvalue < bonferroni_threshold, na.rm = TRUE)

# Here we "tidy" the data using a series of pipes to return a tibble (tbl_df) with feature_id column with ENSEMBL gene ids and remaining columns from the results object
# note: the biobroom package has functionality to streamline this operation
res.lfcShrink.tbl_df <- res.lfcShrink %>%
  as.data.frame() %>%
  rownames_to_column(var = "feature_id") %>%
  as_tibble()

res.lfcShrink.tbl_df %>% 
  arrange(padj) # sort tibble in ascending order on adjusted p-value (FDR)

sum(res.lfcShrink$padj < 0.05, na.rm = TRUE)

# upregulated genes: 
sum(res.lfcShrink$padj < 0.05 & res.lfcShrink$log2FoldChange > 0, na.rm = TRUE)

# Expected false positives
sum(res.lfcShrink$padj < 0.05, na.rm = TRUE) * 0.05

# Volcano plot
res.lfcShrink.tbl_df %>% # pipe the data.frame (tibble) to mutate to add a column named "neg_log10_padj" with negative log10 adjusted p-values
  mutate(neg_log10_padj = -1*log10(padj)) %>% # pipe the modified data.frame (tibble) to first (data) argument of ggplot
  ggplot(aes(x = log2FoldChange, y = neg_log10_padj)) + # define which columns (variables) to plot on x and y axes with aes()
  geom_point(color = 'gray') + # add gray points
  geom_point( data = ~.x %>% filter(log2FoldChange < -2 & neg_log10_padj > 2), color = 'orange') + # add a second layer of orange points on subset of data
  geom_point( data = ~.x %>% filter(log2FoldChange > 2 & neg_log10_padj > 2), color = 'light blue') + # add a third layer of blue points on subset of data
  theme_bw()

#Install AnnotationDbi
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("AnnotationDbi")

significant_genes.v <- res.lfcShrink.tbl_df %>%
  filter(!is.na(padj)) %>% # retain only genes that don't have NA in padj column
  filter(padj < 0.05) %>% # retain only genes with FDR < 0.05
  pull(feature_id)

library(org.Hs.eg.db)
ensembl2gene.tbl_df <- AnnotationDbi::select(org.Hs.eg.db, keys=significant_genes.v, 
                                             columns="SYMBOL", keytype="ENSEMBL") %>%
  as_tibble()
ensembl2gene.tbl_df

inner_join(x = res.lfcShrink.tbl_df, # DESeq2 results tibble
           y = ensembl2gene.tbl_df, # ENSEMBL to gene symbol map tibble
           by = join_by(feature_id == ENSEMBL) ) %>%
  arrange(padj) 

# Extract LAMC2
inner_join(x = res.lfcShrink.tbl_df, # DESeq2 results tibble
           y = ensembl2gene.tbl_df, # ENSEMBL to gene symbol map tibble
           by = join_by(feature_id == ENSEMBL) ) %>%
  filter(SYMBOL == 'LAMC2')

# GO enrichment analysis
tribble(~`DEG class`,~`Genes annotated with GO of interest`,~`Genes not annotated with GO of interest`,~Total,
        'DEG','n11','n12','n1+',
        'not DEG','n21','n22','n2+',
        'Total','n+1','n+2','n')

universe_genes.v <- res.lfcShrink.tbl_df %>%
  filter(!is.na(padj)) %>% # here we preserve any gene that does not have missing data after independent filtering in the results object
  pull(feature_id)

length(universe_genes.v)

# This will output a data.frame-like object of class enrichResult
library(clusterProfiler)
bp.enrichResult <- enrichGO(gene = significant_genes.v, # specifify the significant set of genes
                            OrgDb = org.Hs.eg.db,
                            keyType = "ENSEMBL",
                            ont = "BP", # select Biological Process ontology. Molecular Function (MF) and Cellular Compartment (CC) may also be interesting
                            pAdjustMethod = "BH",
                            universe = universe_genes.v) # specify the background set of genes

dotplot(bp.enrichResult, showCategory=10)

bp.enrichResult %>% # pipe the data.frame-like enrichResult object to the as_tibble function
  as_tibble() %>% # coerce to a tibble (a data.frame with benefits)
  filter(p.adjust < 0.05)
