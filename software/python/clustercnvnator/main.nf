// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PYTHON_CLUSTERCNVNATOR {
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
    tuple val(meta), path(cnvnator_format)
    path(gapsRef)

    output:
    tuple val(meta), path("merged/*cluster.txt"), emit: cnvnator_cluster
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    mkdir calls
    echo $cnvnator_format"\t"${meta.id} > ids.map
    grep -v "GL" $cnvnator_format > calls/$cnvnator_format
    mkdir merged
    merge_cnvnator_results.py -i ./calls/ -a ids.map -o ./merged/ -g $gapsRef

    echo \$(python --version 2>&1) | sed 's/^.*Python //; s/Using.*\$//' > ${software}.version.txt
    """
}
