process ALPHAGENOME {
    tag "${params.species}:${tool}:${params.version}:${id}"

    label 'simple'
    label 'alphagenome'

    publishDir("${params.output_dir}/annotations/${tool}", mode: 'copy')

    input:
    tuple val(id), path(file), path(index), val(tool)

    output:
    tuple val("${params.species}"), val("${tool}"), val("${params.version}"), val(id),
          path("${params.species}.${tool}.${params.version}.${id}.scores.tsv"),
          env(nvariants)

    secret 'API_KEY'
    // nextflow secret set API_KEY <api_key>

    script:
    """
    #!/bin/bash
    query_alphagenome.py \
        --api_key \$API_KEY \
        --vcf_file ${file} \
        --organism ${params.species} \
        --sequence_length ${params.seq_length} \
        --output ${params.species}.${tool}.${params.version}.${id}.scores.tsv

    # Count the number of variants
    nvariants=\$(cat ${params.species}.${tool}.${params.version}.${id}.scores.tsv | wc -l)
    """
}
