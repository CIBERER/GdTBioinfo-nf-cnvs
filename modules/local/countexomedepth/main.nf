process COUNTEXOMEDEPTH {
    tag "$meta_cohort.id"
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
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    tuple val(meta_cohort), path(bams, stageAs: 'input_bams/*'), path(bed_file), path(fasta_file)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta_cohort), path("${prefix}.Rdata"), emit: rdata
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '' // For additional R script parameters, if any, passed via task.ext.args
    def prefix = task.ext.prefix ?: "${meta_cohort.id}"
    def bam_file_paths = bams.collect{ it.toString() }.join(' ')

    """
    countexomedepth.R \\
        $args \\
        $bed_file \\
        $fasta_file \\
        $bam_file_paths

    # The R script saves output as Exome_Depth1.Rdata by default.
    # Rename it to match the output channel expectation, using the prefix.
    mv Exome_Depth1.Rdata ${prefix}.Rdata

    # Version gathering
    R_VERSION=\\$(R --version | head -n 1 | sed 's/R version \\\\([^ ]*\\\\) .*/\\\\1/')
    EXOMEDEPTH_VERSION=\\$(Rscript -e "library(ExomeDepth); cat(as.character(packageVersion('ExomeDepth')))" | sed -e 's/\\\\[1\\\\] \\"//' -e 's/\\"//')

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \${R_VERSION}
        bioconductor-exomedepth: \${EXOMEDEPTH_VERSION}
    END_VERSIONS
    """

    stub: // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    def prefix = task.ext.prefix ?: "${meta_cohort.id}"
    """
    touch ${prefix}.Rdata
    touch versions.yml
    """
}
