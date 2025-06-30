process SPLICEAI {
    tag "${params.assembly}:${params.tool}:${params.version}:${id}"

    label 'simple'
    label 'spliceai'

    publishDir("${params.output_dir}/annotations", mode: 'copy')

    input:
    tuple val(id), path(file), path(index)

    output:
    tuple val("${params.assembly}"), val("${params.tool}"), val("${params.version}"),
          val(id),
          path("${params.assembly}.${params.tool}.${params.version}.${id}.vcf.gz"),
          path("${params.assembly}.${params.tool}.${params.version}.${id}.vcf.gz.tbi")

    script:
    def args = []
    if ( params.masked )           { args << "-M 1" }
    if ( params.fasta != null )    { args << "-R ${params.fasta}" }
    if ( params.assembly != null ) { args << "-A ${params.assembly.toLowerCase()}" }
    def args_str = args.join(' ')

    """
    #!/bin/bash
    spliceai \
        -I ${file} \
        -O ${params.assembly}.${params.tool}.${params.version}.${id}.vcf.gz \
        ${args_str}

    touch ${params.assembly}.${params.tool}.${params.version}.${id}.vcf.gz.tbi
    """
}
