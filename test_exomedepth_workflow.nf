#!/usr/bin/env nextflow

/*
========================================================================================
                    ExomeDepth Test Workflow
========================================================================================
 Test workflow to validate COUNTEXOMEDEPTH and CALLEXOMEDEPTH modules
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

// Import modules
include { COUNTEXOMEDEPTH } from './modules/local/countexomedepth/main'
include { CALLEXOMEDEPTH } from './modules/local/callexomedepth/main'

// Parameters
params.test_data_dir = "${projectDir}/tests/data"
params.outdir = "results_exomedepth_test"
params.publish_dir_mode = "copy"

log.info """
=======================================================
    ExomeDepth Test Workflow
=======================================================
Test data directory: ${params.test_data_dir}
Output directory: ${params.outdir}
=======================================================
"""

workflow {
    
    // Define test data paths
    bed_file = file("${params.test_data_dir}/regions.bed", checkIfExists: true)
    fasta_file = file("${params.test_data_dir}/chr17.fa", checkIfExists: true)
    
    // Step 1 Input: ALL BAMs for cohort matrix generation
    // Collect ALL BAMs and BAIs for the cohort
    all_bams_and_bais = Channel.fromPath("${params.test_data_dir}/*.{bam,bam.bai}", checkIfExists: true)
        .collect()
    
    // Create meta for cohort
    cohort_meta = Channel.value([id: 'test_cohort_exomedepth'])
    
    // Combine cohort meta with ALL BAMs/BAIs for COUNTEXOMEDEPTH
    cohort_input = cohort_meta.combine(all_bams_and_bais)
    
    // Step 1: Run COUNTEXOMEDEPTH to generate count matrix
    COUNTEXOMEDEPTH(
        cohort_input,
        bed_file,
        fasta_file
    )
    
    // Step 2: Create individual sample channels for CALLEXOMEDEPTH
    // Select a few samples to test individual CNV calling (paralelizable)
    individual_samples = Channel.fromPath("${params.test_data_dir}/HG01*.bam")
        .take(3) // Test with first 3 samples
        .map { bam ->
            def sample_id = bam.baseName
            def meta = [id: sample_id]
            return [meta, bam]
        }
    
    // Step 3: Run CALLEXOMEDEPTH for each individual sample
    // The count matrix (.Rdata) is broadcast to all individual samples
    CALLEXOMEDEPTH(
        COUNTEXOMEDEPTH.out.count_exomedepth_rdata.map { meta, rdata -> rdata }.first(),
        individual_samples
    )
    
    // Collect and display results
    COUNTEXOMEDEPTH.out.count_exomedepth_rdata.view { meta, rdata ->
        "✅ Count matrix generated: ${rdata}"
    }
    
    CALLEXOMEDEPTH.out.cnv_calls.view { meta, csv ->
        "🔍 CNV calls for ${meta.id}: ${csv}"
    }
}

workflow.onComplete {
    log.info """
=======================================================
    ExomeDepth Test Workflow - COMPLETED
=======================================================
Success: ${workflow.success}
Duration: ${workflow.duration}
Results directory: ${params.outdir}
=======================================================
    """
}
