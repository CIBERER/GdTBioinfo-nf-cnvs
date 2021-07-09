//
// Detect CNVs with CNVNATOR
//

// Define parameters for modules. By default, create an empty list.
// These parameters refer to the program itself and to nextflow modules options.
params.cnvnator_options = [:]
params.format_options   = [:]
params.cluster_options  = [:]

// Include modules files. Add options list.
include { CNVNATOR } from '../../cnvnator/main.nf' addParams( options: params.cnvnator_options )
include { PYTHON_FORMATCNVNATOR } from '../../python/formatcnvnator/main.nf' addParams( options: params.format_options  )
include { PYTHON_CLUSTERCNVNATOR } from '../../python/clustercnvnator/main.nf' addParams( options: params.cluster_options  )


// Define workflow
workflow RUN_CNVNATOR {

  // Define inputs of the workflow. Include short documentation of each input
  take:
  ch_input /// channel: [val(meta), path(bam), path(bai)]
  fasta    /// channel: [path/fasta/files]
  genome   /// value: genome_reference
  binSize  /// value: cnvnator_binSize
  gapsRef  /// channel: [path/gaps/Ref]

  // Define workflow steps. Include brief explanation of each step
  main:
  /// Run CNVNATOR
  CNVNATOR(ch_input, fasta, genome, binSize)

  /// Format CNVNATOR calls
  PYTHON_FORMATCNVNATOR(CNVNATOR.out.txt)

  /// Cluster CNVNATOR calls
  PYTHON_CLUSTERCNVNATOR(PYTHON_FORMATCNVNATOR.out.cnvnator_format, gapsRef)

  // Define outputs of the workflow. Include short documentation of each output
  emit:
  cnvnator_orig        = CNVNATOR.out.txt                                 /// channel: [ val(meta), txt  ]
  cnvnator_format      = PYTHON_FORMATCNVNATOR.out.cnvnator_format              /// channel: [ val(meta), txt  ]
  cnvnator_cluster     = PYTHON_CLUSTERCNVNATOR.out.cnvnator_cluster      /// channel: [ val(meta), txt  ]
  cnvnator_version     = CNVNATOR.out.version                             /// path: *.version.txt
  format_version       = PYTHON_FORMATCNVNATOR.out.version                /// path: *.version.txt
  cluster_version      = PYTHON_CLUSTERCNVNATOR.out.version               /// path: *.version.txt

}
