process COUNTEXOMEDEPTH {
    tag "$meta_cohort.id"
    label 'process_low'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    //conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-exomedepth:1.1.16--r43hfb3cda0_3':
        'quay.io/biocontainers/r-exomedepth:1.1.16--r43hfb3cda0_3' }"


    //todos los canales pasan como un meta para pasarlos al bed y al fasta; discutir 

    input:
        val prefix
        path script
        tuple val(meta_cohort), path(bams)
        path(bed)
        path fasta_files

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta_cohort), path("${prefix}.Rdata"), emit: count_exomedepth_rdata
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    // Define el prefijo aquí para que sea visible en `output`
    //def prefix = task.ext.prefix ?: (meta_cohort && meta_cohort.id ? meta_cohort.id : "default_process_id")

    script:
    """
    Rscript $script \\
        $prefix \\
        $bed \\
        ${fasta_files[0]} \\
        $bams

    # El script R ahora se encarga de guardar el archivo con el nombre correcto.
    # No necesitas mv Exome_Depth1.Rdata "${prefix}.Rdata"

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
    touch "${prefix}.Rdata"
    touch versions.yml
    """
}
