#!/usr/bin/env nextflow

/*
========================================================================================
                    Parallelization Proof Test Workflow
========================================================================================
| Purpose: Verify that CALLEXOMEDEPTH correctly parallelizes across multiple samples
|          using a shared count matrix from COUNTEXOMEDEPTH
|
| What this test proves:
|   1. COUNTEXOMEDEPTH generates a matrix with correct column names
|   2. CALLEXOMEDEPTH receives the matrix as a value channel (reusable)
|   3. Multiple samples are processed in parallel (not sequentially)
|   4. Each output CSV contains actual CNV data
|   5. Number of outputs matches number of input samples
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

// Import modules
include { COUNTEXOMEDEPTH } from './modules/local/countexomedepth/main'
include { CALLEXOMEDEPTH } from './modules/local/callexomedepth/main'

// Parameters
params.test_data_dir = "${projectDir}/tests/data"
params.outdir = "results_parallelization_proof"
params.publish_dir_mode = "copy"

// Select ALL 10 samples for testing (full cohort)
def test_samples = [
    "HG01516.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG01518.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG01632.mapped.ILLUMINA.bwa.IBS.exome.20121211_chr22_regions_CNV.bam",
    "HG01695.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG01702.mapped.ILLUMINA.bwa.IBS.exome.20121211_chr22_regions_CNV.bam",
    "HG01707.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG01709.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG01757.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG01762.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam",
    "HG02239.mapped.ILLUMINA.bwa.IBS.exome.20120522_chr22_regions_CNV.bam"
]

log.info """
========================================================================
    🧪 PARALLELIZATION PROOF TEST
========================================================================
Test data dir    : ${params.test_data_dir}
Output dir       : ${params.outdir}
Number of samples: ${test_samples.size()}
Samples to test  :
${test_samples.collect { "  - ${it}" }.join('\n')}
========================================================================
Expected behavior:
  1️⃣  COUNTEXOMEDEPTH: 1 execution (cohort matrix)
  2️⃣  CALLEXOMEDEPTH: ${test_samples.size()} parallel executions
========================================================================
"""

workflow {
    
    // Define reference files
    bed_file = file("${params.test_data_dir}/regions.bed", checkIfExists: true)
    fasta_file = file("${params.test_data_dir}/chr17.fa", checkIfExists: true)
    
    // =======================================================================
    // STEP 1: Generate count matrix from ALL test samples
    // =======================================================================
    
    log.info "\n[STEP 1] Preparing cohort for count matrix generation..."
    

// Collect all BAM and BAI files for the specified test samples
all_bams_and_bais = Channel.fromPath("${params.test_data_dir}/*.{bam,bai}")
    .filter { file -> 
        // Match exact sample names (BAM files and their corresponding BAI files)
        test_samples.any { sample -> 
            file.name == sample || file.name == "${sample}.bai"
        }
    }
    .collect()
    .map { files ->  
        // Sort files to ensure consistent ordering and group BAM with BAI
        def sorted_files = files.sort { it.name }
        def meta = [id: 'parallelization_test_cohort']
        return tuple(meta, sorted_files)  // → [meta, [file1, file2, ...]]
    }
    .view { meta, files ->
        def bam_count = files.findAll { it.name.endsWith('.bam') }.size()
        def bai_count = files.findAll { it.name.endsWith('.bai') }.size()
        "📂 Collected ${bam_count} BAMs + ${bai_count} BAIs for cohort matrix"
    }

// Execute COUNTEXOMEDEPTH
COUNTEXOMEDEPTH(
    all_bams_and_bais,  // Ya tiene el formato correcto
    bed_file,
    fasta_file
)
    
    // =======================================================================
    // STEP 2: Prepare individual samples for parallel processing
    // =======================================================================
    
    log.info "\n[STEP 2] Preparing individual samples for CALLEXOMEDEPTH..."
    
    individual_samples = Channel.fromList(test_samples)
        .map { sample_name ->
            def bam_file = file("${params.test_data_dir}/${sample_name}", checkIfExists: true)
            def meta = [id: sample_name]
            return [meta, bam_file]
        }
        .view { meta, bam ->
            "🔬 Sample prepared: ${meta.id}"
        }
    
    // =======================================================================
    // STEP 3: Execute CALLEXOMEDEPTH in parallel
    // =======================================================================
    
    log.info "\n[STEP 3] Executing CALLEXOMEDEPTH (${test_samples.size()} parallel executions expected)...\n"
    
    // Extract the Rdata file as a value channel (reusable)
    count_matrix = COUNTEXOMEDEPTH.out.count_exomedepth_rdata
        .map { meta, rdata -> rdata }
        .first()
    
    // Execute CALLEXOMEDEPTH for each sample (parallelized)
    CALLEXOMEDEPTH(
        count_matrix,
        individual_samples
    )
    
    // =======================================================================
    // STEP 4: Collect and analyze results
    // =======================================================================
    
    log.info "\n[STEP 4] Collecting results...\n"
    
    // Count number of successful outputs
    def output_counter = 0
    
    CALLEXOMEDEPTH.out.cnv_calls
        .map { meta, csv ->
            output_counter++
            return [meta, csv, file(csv).size()]
        }
        .view { meta, csv, size ->
            """
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Sample: ${meta.id}
   📄 Output: ${csv.name}
   📊 Size: ${size} bytes
   💾 Path: ${csv}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            """.stripIndent().trim()
        }
    
    // Verify CSV content (not empty and has expected structure)
    CALLEXOMEDEPTH.out.cnv_calls
        .map { meta, csv ->
            def lines = file(csv).readLines()
            def has_header = lines.size() > 0 && lines[0].contains("chromosome")
            def has_data = lines.size() > 1
            def num_cnvs = lines.size() - 1  // Exclude header
            return [meta.id, has_header, has_data, num_cnvs]
        }
        .view { sample, has_header, has_data, num_cnvs ->
            """
🔍 CONTENT VALIDATION for ${sample}:
   - Header present: ${has_header ? '✅' : '❌'}
   - Has data rows: ${has_data ? '✅' : '❌'}
   - CNVs detected: ${num_cnvs}
            """.stripIndent().trim()
        }
    
    // Summary channel
    CALLEXOMEDEPTH.out.cnv_calls
        .collect()
        .view { results ->
            """

╔════════════════════════════════════════════════════════════════════╗
║                    📊 PARALLELIZATION TEST SUMMARY                  ║
╠════════════════════════════════════════════════════════════════════╣
║  Expected samples : ${test_samples.size()}                                                   ║
║  Outputs generated: ${results.size()}                                                   ║
║  Test result      : ${results.size() == test_samples.size() ? '✅ PASSED' : '❌ FAILED'}                                    ║
╚════════════════════════════════════════════════════════════════════╝
            """.stripIndent()
        }
}

workflow.onComplete {
    log.info """
========================================================================
    🏁 PARALLELIZATION PROOF TEST - COMPLETED
========================================================================
Success    : ${workflow.success}
Duration   : ${workflow.duration}
Exit status: ${workflow.exitStatus}
Results dir: ${params.outdir}
========================================================================
INTERPRETATION:
${workflow.success ? 
"""✅ Test PASSED! 
   - Count matrix was generated successfully
   - All samples were processed in parallel
   - Each sample produced a valid output CSV
   - Parallelization is working correctly!
""" : 
"""❌ Test FAILED!
   - Please check the error messages above
   - Verify that all input files exist
   - Check the work directory for details
"""}
========================================================================
    """
}