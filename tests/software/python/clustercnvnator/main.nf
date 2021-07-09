#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PYTHON_CLUSTERCNVNATOR } from '../../../../software/python/clustercnvnator/main.nf' addParams( options: [:] )
include { PYTHON_FORMATCNVNATOR } from '../../../../software/python/formatcnvnator/main.nf' addParams( options: [:] )
include { CNVNATOR } from '../../../software/cnvnator/main.nf' addParams( options: [:] )

workflow test_python_clustercnvnator {

    input = [ [ id:'test' ], // meta map
    file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam'], checkIfExists: true),
    file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam_bai'], checkIfExists: true) ]

    CNVNATOR ( input,
      file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true),
      "hg19",
      "100" )
    PYTHON_FORMATCNVNATOR ( CNVNATOR.out.txt )
    PYTHON_CLUSTERCNVNATOR ( PYTHON_FORMATCNVNATOR.out.cnvnator_format,
                            file(params.test_data['sarscov2']['genome']['test_bed'], checkIfExists: true) )
}
