// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process CALLEXOMEDEPTH {
    tag "$meta.id"
    label 'process_low'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-exomedepth:1.1.16--r43hfb3cda0_3':
        'quay.io/biocontainers/r-exomedepth:1.1.16--r43hfb3cda0_3' }"

    input:
    path(exome_count_matrix) // .Rdata file from COUNTEXOMEDEPTH module
    tuple val(meta), path(bam) // Individual sample to analyze

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("${meta.id}_exomedepth.csv"), emit: cnv_calls
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    Rscript ${projectDir}/bin/callexomedepth.R \\
        $exome_count_matrix \\
        ${meta.id}

    # Following nf-core pattern: script generates fixed filename, Nextflow handles final naming
    mv Results_EXOMEDEPTH.csv ${meta.id}_exomedepth.csv

    # Version gathering
    R_VERSION=\$(R --version | head -n 1 | sed 's/R version \\([^ ]*\\) .*/\\1/')
    EXOMEDEPTH_VERSION=\$(Rscript -e "library(ExomeDepth); cat(as.character(packageVersion('ExomeDepth')))" | sed -e 's/\\[1\\] \"//' -e 's/\"//')

    cat <<-END_VERSIONS > versions.yml
    ${task.process}:
        r-base: \$R_VERSION
        bioconductor-exomedepth: \$EXOMEDEPTH_VERSION
    END_VERSIONS
    """

    stub:
    """
    touch "${meta.id}_exomedepth.csv"
    touch versions.yml
    """
}
