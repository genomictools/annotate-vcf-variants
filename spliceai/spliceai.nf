process SPLICEAI {
    tag "${params.assembly}:${tool}:${params.version}:${id}"

    label 'simple'
    label 'spliceai'

    publishDir("${params.output_dir}/annotations/${tool}", mode: 'copy')

    input:
    tuple val(id), path(file), path(index), val(tool)

    output:
    tuple val("${params.assembly}"), val("${tool}"), val("${params.version}"), val(id),
          path("${params.assembly}.${tool}.${params.version}.${id}.vcf.gz"),
          path("${params.assembly}.${tool}.${params.version}.${id}.vcf.gz.tbi"),
          env(nvariants)

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
        -O ${params.assembly}.${tool}.${params.version}.${id}.vcf.gz \
        ${args_str}

    touch ${params.assembly}.${tool}.${params.version}.${id}.vcf.gz.tbi

    nvariants=\$(zcat ${params.assembly}.${tool}.${params.version}.${id}.vcf.gz | grep -v '^#' | wc -l)
    """
}
