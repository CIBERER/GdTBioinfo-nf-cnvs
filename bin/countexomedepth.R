# load packages
library(ExomeDepth)
library(dplyr)
library(GenomicRanges)
library(Rsamtools)
library(Biostrings)
#library(readr)


args=commandArgs(trailingOnly = T) #string vector arg witch contains the entries at command lines

bed_file <- args[1]
fasta_file <- args[2]
all_bam_related_files <- args[3:length(args)]

# Filter the arguments to only select .bam files.
# The .bai files will be in the work directory but won't be processed directly.
bam_files <- all_bam_related_files[grepl("\\.bam$", all_bam_related_files)]
print(bam_files)

rm(args)


#bed <- as.data.frame(read_delim(bedFile, 
                                #delim = "\t", escape_double = FALSE, 
                                #col_names = FALSE, trim_ws = TRUE))

# Cargar el fichero de regiones (BED)
my_bed <- read.delim(bed_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
my_bed <- my_bed[,1:4]
colnames(my_bed) <- c("chromosome", "start", "end", "name")

# Calculate GC content and add it as the 5th column
# 1. Create a GRanges object from the BED data
#    BED files are 0-based for start, GRanges are 1-based, so we add 1.
my_bed_granges <- GRanges(seqnames = my_bed$chromosome,
                          ranges = IRanges(start = my_bed$start + 1, end = my_bed$end))


# 2. Open the reference FASTA file
reference_fasta <- FaFile(file = fasta_file)

# 3. Get sequences for each BED region
sequences <- getSeq(reference_fasta, my_bed_granges)

# 4. Calculate GC frequency and add it to the data frame
my_bed$gc.content <- as.vector(letterFrequency(sequences, letters = "GC", as.prob = TRUE))

# Crear la matriz de cuentas
# getBamCounts will now use the 5th column 'gc.content' for correction
all.counts <- getBamCounts(bed.frame = my_bed,
                           bam.files = bam_files,
                           include.chr = FALSE)

# Prepare optimized data structures for module 2 (callexomedepth)
# Only export what's needed: dataframe and matrix, no BAM paths

# 1. ExomeCount.dafr: Complete dataframe with regions + counts
ExomeCount.dafr <- as.data.frame(all.counts)
# Rename 'name' column to 'exon' as expected by module 2
colnames(ExomeCount.dafr)[colnames(ExomeCount.dafr) == "name"] <- "exon"

# 2. ExomeCount.mat: Numeric matrix of counts only (exclude region info)
# Extract only the count columns (typically from column 6 onwards after: chr, start, end, exon, gc.content)
count_columns <- 6:ncol(ExomeCount.dafr)
ExomeCount.mat <- as.matrix(ExomeCount.dafr[, count_columns])

# Save optimized data: only dataframe and matrix, no BAM paths
# This reduces file size and avoids redundancy with Nextflow BAM management
save(ExomeCount.dafr, ExomeCount.mat, file = "ExomeCount.Rdata")


