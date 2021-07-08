// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PYTHON_FORMATCNVNATOR {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }


    conda (params.enable_conda ? "bioconda::bioconda-utils=0.17.8" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bioconda-utils:0.17.8--pyhdfd78af_0"
    } else {
        container "quay.io/biocontainers/bioconda-utils:0.17.8--pyhdfd78af_0"
    }

    input:
    tuple val(meta), path(cnvnator_res)

    output:
    tuple val(meta), path("*.cnvnator_formated.txt"), emit: cnvnator_format
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    format_cnvnator_results.py ${cnvnator_res} ${prefix}.cnvnator_formated.txt

    echo \$(python --version 2>&1) | sed 's/^.*Python //; s/Using.*\$//' > ${software}.version.txt
    """
}
