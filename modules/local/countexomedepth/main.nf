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


    input: //todos los canales pasan como un meta para pasarlos al bed y al fasta; discutir 
        tuple val(meta_cohort), path(bams) //cambiar nombres a mas cortos
        path(bed) 
        path(fasta)
//el prefix (id) debe ser meta_cohort.id
    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta_cohort), path("${meta_cohort.id}.Rdata"), emit: count_exomedepth_rdata // mas descriptivo rdata porque se va a usar en el subworkflow
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions
//Revisar prefix porque no se van a sobreescribir los archivos porque están en las carpetas no introducir en el input
    when:
    task.ext.when == null || task.ext.when

    script:
    //nextflow.enable.moduleBinaries = true 
    //borrar todo al cambiar path por val por los enlaces simbolicos 
    """
    Rscript ${projectDir}/bin/countexomedepth.R \\
        $bed \\
        $fasta \\
        $bams

    # Following nf-core pattern: script generates fixed filename, Nextflow handles final naming
    mv ExomeCount.Rdata ${meta_cohort.id}.Rdata

    # Version gathering
    R_VERSION=\$(R --version | head -n 1 | sed 's/R version \\([^ ]*\\) .*/\\1/')
    EXOMEDEPTH_VERSION=\$(Rscript -e "library(ExomeDepth); cat(as.character(packageVersion('ExomeDepth')))" | sed -e 's/\\[1\\] \"//' -e 's/\"//')

    cat <<-END_VERSIONS > versions.yml
    ${task.process}:
        r-base: \$R_VERSION
        bioconductor-exomedepth: \$EXOMEDEPTH_VERSION
    END_VERSIONS
    """
    //cambiar el nombre de prefix en el fichero de R y dejar fijo para que se carge sin cambiar aquí
    stub:
    """
    touch "${meta_cohort.id}.Rdata"
    touch versions.yml
    """
}
