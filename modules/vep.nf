process VEP {
    tag "${id}"

    label 'simple'
    label 'vep'

    publishDir("${params.output_dir}/annotations", mode: 'copy')

    input:
    tuple val(id), path(file), path(index)

    output:
    tuple val("${params.assembly}.${params.vep_version}"), val(id),
          path("${id}.annotated.vcf.gz"),
          path("${id}.annotated.vcf.gz.tbi")

    script:
    """
    #!/bin/bash
    vep \
        -i ${file} \
        -o ${id}.annotated.vcf.gz \
        --species ${params.species} \
        --assembly ${params.assembly} \
        --cache_version ${params.vep_version} \
        --dir_cache ${params.vep_cache} \
        --fasta ${params.fasta} \
        --cache \
        --offline \
        --everything \
        ${params.cadd ? '--plugin CADD,snv=params.cadd_snv,indels=params.cadd_indels' : ''} \
        --format vcf \
        --vcf \
        --compress_output bgzip \
        --fork ${task.cpus}

    tabix ${id}.annotated.vcf.gz
    """
}
