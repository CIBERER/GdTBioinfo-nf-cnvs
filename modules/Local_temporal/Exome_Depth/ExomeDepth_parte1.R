#!/usr/bin/env Rscript

# load packages
library(ExomeDepth)
library(dplyr)
library(readr)


args=commandArgs(trailingOnly = T) #string vector arg witch contains the entries at command lines

inputList <- args
bedFile <- inputList[1]
refgenFile <- inputList[2]
bamsList <- inputList[3:length(args)]

rm(args)


bed <- as.data.frame(read_delim(bedFile, 
                                delim = "\t", escape_double = FALSE, 
                                col_names = FALSE, trim_ws = TRUE))

refgen <- refgenFile

# set global variables
bamFiles <- c(bamsList)

# prepare bed file (4th column is the annotation for each region)
bed <- bed[,1:4]
colnames(bed) <- c("chromosome", "start", "end", "name")

# get counts per bed region
message('\n[INFO] Creating counts matrix')
my.counts <- getBamCounts(bed.frame = bed,  # Ref y test en una matriz de datos con los conteos. 
                          bam.files = bamFiles, 
                          include.chr = FALSE, 
                          referenceFasta = refgen)

ExomeCount.dafr <- as(my.counts, "data.frame")

# prepare the main matrix of read count data
ExomeCount.mat <- as.matrix(ExomeCount.dafr[, grep(names(ExomeCount.dafr), pattern = '*.bam')])

save.image("Exome_Depth1.Rdata")


