#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RUN_CNVNATOR } from '../../../../software/subworkflows/run_cnvnator/main.nf' addParams( options: [:] )

workflow test_subworkflow_runcnvnator {

  // Define each part in a variable to simplify future modifications
  input = [ [ id:'test' ], // meta map
    file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam'], checkIfExists: true),
    file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam_bai'], checkIfExists: true) ]
  fasta = file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)
  genome   = "hg19"
  binSize  = "100"
  gapsRef  = file(params.test_data['sarscov2']['genome']['test_bed'], checkIfExists: true)

  RUN_CNVNATOR (input, fasta, genome, binSize, gapsRef)

}
