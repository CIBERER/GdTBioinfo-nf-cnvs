#!/usr/bin/env Rscript

# load packages
library(ExomeDepth)
library(dplyr)
# library(readr)  # Using base R write.csv instead

data(ExomeCount)

args=commandArgs(trailingOnly = T)

#cargar nombre del bam a analizar

inputList_2 <- args
load(inputList_2[1])

sampname <- inputList_2[2]

# Validate that sample exists in count matrix
if (!sampname %in% colnames(ExomeCount.dafr)) {
  message("\n[ERROR] Sample '", sampname, "' not found in count matrix!")
  message("[ERROR] Available columns: ", paste(colnames(ExomeCount.dafr), collapse = ", "))
  stop(paste0("Sample '", sampname, "' not found in count matrix columns!"))
}

# OPTIONAL DEBUG: Uncomment lines below for detailed diagnostics
# message("\n=== DIAGNOSTIC INFO ===")
# message(paste0("[DEBUG] Sample name: '", sampname, "'"))
# message("[DEBUG] Available columns: ", paste(colnames(ExomeCount.dafr), collapse = ", "))
# message("[DEBUG] ✅ Sample column found in matrix!")
# message("======================\n")
results <- data.frame(matrix(ncol = 12, nrow = 0))
colnames(results) <- c("start.p", "end.p", "type", "nexons", "start", "end", 
                       "chromosome", "id", "BF", "reads.expected", "reads.observed", "reads.ratio")  # Añadir nombres correctos

rm(args)
# results <- data.frame(NULL) # to write results

# Crear función para agregar CNV.calls con el sample_id que puedan no recibir CNV -- quitar cuando sean datos grandes?
add_sample_id_to_results <- function(results_df, cnv_calls, sampname) {
  # Comprobar si hay eventos en cnv_calls
  if (nrow(cnv_calls) == 0) {
    # Si no hay eventos, añadir una fila con sample_id = sampname y el resto como NA o 0
    no_event_row <- data.frame(matrix(NA, nrow = 1, ncol = ncol(results_df)))
    names(no_event_row) <- names(results_df)  # Asegurarse que coincidan los nombres de columnas
    no_event_row$sample_id <- sampname
    results_df <- rbind(results_df, no_event_row)
  } else {
    # Verificar que cnv_calls tenga las mismas columnas que results_df
    missing_columns <- setdiff(names(results_df), names(cnv_calls))
    
    # Si faltan columnas en cnv_calls, agregarlas con NA
    if (length(missing_columns) > 0) {
      for (col in missing_columns) {
        cnv_calls[[col]] <- NA
      }
    }
    
    # Reordenar las columnas de cnv_calls para que coincidan con results_df
    cnv_calls <- cnv_calls[, names(results_df)]
    
    # Si hay eventos, añadir sample_id a cnv_calls
    cnv_calls$sample_id <- sampname
    results_df <- rbind(results_df, cnv_calls)
  }
  
  return(results_df)
}


# message(paste0("\n[INFO] Creating reference set for ", sampname))
  
# Create the aggregate reference set for this sample
my.test_1 = ExomeCount.dafr[[sampname]]
my.test=as.numeric(my.test_1)


my.reference.set <- as.matrix(ExomeCount.dafr %>% select(-all_of(sampname)))
# Dynamically find count columns (after chromosome, start, end, exon, gc.content)
count_columns <- 5:ncol(my.reference.set)  # Start from column 5 (after region info)
my.reference.set <- my.reference.set[,count_columns]
my.reference.set <- apply(my.reference.set, 2, as.numeric)
my.reference.set <- as.matrix(my.reference.set)
my.choice <- select.reference.set(test.counts = my.test,
                                  reference.counts = my.reference.set,
                                  bin.length = (as.numeric(ExomeCount.dafr$end - ExomeCount.dafr$start)/1000),
                                  n.bins.reduced = 10000)


  
message('\n[INFO] Computing correlation between sample and references...\n')

my.matrix <- ( ExomeCount.dafr[, my.choice$reference.choice, drop = FALSE])
my.reference.selected <- apply(X = my.matrix,
                               MAR = 1,
                               FUN = sum)
my.ref.counts = ExomeCount.mat[, my.choice$reference.choice, drop = FALSE]
correlation = cor(my.test, apply(my.ref.counts, 1, mean))
message(paste("\n[INFO] Correlation between reference and tests count is", round(correlation,4)))
  
message('\n[INFO] Creating the ExomeDepth object')
all.exons <- new('ExomeDepth',
                 test = my.test,
                 reference = my.reference.selected,
                 formula = 'cbind(test, reference) ~ 1')
  
# Call the CNVs
# message('\n[INFO] Calling CNVs')
# all.exons <- CallCNVs(x = all.exons,
#                       transition.probability = 10^-4,
#                       chromosome = ExomeCount.dafr$chromosome,
#                       start = ExomeCount.dafr$start,
#                       end = ExomeCount.dafr$end,
#                       name=ExomeCount.dafr$exon)
message('\n[INFO] Calling CNVs')
all.exons <- CallCNVs(x = all.exons,
                      transition.probability = 10^-1,
                      chromosome = ExomeCount.dafr$chromosome,
                      start = ExomeCount.dafr$start,
                      end = ExomeCount.dafr$end,
                      name=ExomeCount.dafr$exon,
                      expected.CNV.length = 20)

results <- add_sample_id_to_results(results, all.exons@CNV.calls, sampname)
# all.exons@CNV.calls$sample_id <- sampname # set sample name
# results <- rbind(results, all.exons@CNV.calls)  # append to results}
message('\n[INFO] Writting results')
# output.file <- paste0("batch_", 123, ".exomeDepth.csv")
# write.csv(file = output.file, x = results, row.names = FALSE)
write.csv(results, "Results_EXOMEDEPTH.csv", row.names = FALSE)
