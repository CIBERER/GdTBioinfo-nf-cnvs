// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process CNVNATOR {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::cnvnator=0.4.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/cnvnator:0.4.1--h9c7f56d_2"
    } else {
        container "quay.io/biocontainers/cnvnator:0.4.1--h9c7f56d_2"
    }

    input:
    tuple val(meta), path(bam), path(bai)
    path(fasta)
    val(genome)
    val(bin_size)

    output:
    tuple val(meta), path("*.txt"), emit: txt
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    cnvnator -genome $genome -root ${meta.id}.root -tree $bam
    cnvnator -genome $genome -root ${meta.id}.root -his $bin_size
    cnvnator -root "${meta.id}.root" -stat $bin_size
    cnvnator -root "${meta.id}.root" -partition $bin_size -ngc
    cnvnator -root "${meta.id}.root" -call $bin_size -ngc > ${prefix}.txt

    echo \$(cnvnator 2>&1) | sed 's/^.*CNVnator //; s/Usage.*//; s/Using.*\$//' > ${software}.version.txt
    """
}
