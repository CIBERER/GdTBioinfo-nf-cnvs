#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CNVNATOR } from '../../../software/cnvnator/main.nf' addParams( options: [:] )

workflow test_cnvnator {

    input = [ [ id:'test' ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam'], checkIfExists: true),
              file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam_bai'], checkIfExists: true) ]

    CNVNATOR ( input,
              file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true),
              "hg19",
              "100" )
}
