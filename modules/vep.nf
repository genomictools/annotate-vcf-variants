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
    def args = []
    if ( params.cadd )     { args << "--plugin CADD,snv=${params.cadd_snv},indels=${params.cadd_indel}" }
    if ( params.spliceai ) { args << "--plugin SpliceAI,snv=${params.spliceai_snv},indel=${params.spliceai_indel}" }
    if ( params.gnomad )   { args << "--custom ${params.gnomad_file},gnomAD,vcf,exact,0,AF" }
    def args_str = args.join(' ')

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
        --format vcf \
        --vcf \
        --compress_output bgzip \
        --fork ${task.cpus} \
        ${args_str}

    tabix ${id}.annotated.vcf.gz
    """
}
