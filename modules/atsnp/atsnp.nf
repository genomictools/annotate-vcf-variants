process ATSNP {
    tag "${params.species}:${tool}:${params.version}:${id}"

    label 'simple'
    label 'atsnp'

    publishDir("${params.output_dir}/annotations/${tool}", mode: 'copy')

    input:
    tuple val(id), path(file), path(index), val(tool)

    output:
    tuple val("${params.species}"), val("${tool}"), val("${params.version}"), val(id),
          path("${params.species}.${tool}.${params.version}.${id}.scores.tsv"),
          env(nvariants)

    script:
    """
    #!/bin/bash
    call_atsnp.R ${file} ${params.motifs} ${params.species}.${tool}.${params.version}.${id}.scores.tsv    
    nvariants=\$(cat ${params.species}.${tool}.${params.version}.${id}.scores.tsv | wc -l)
    """
}
