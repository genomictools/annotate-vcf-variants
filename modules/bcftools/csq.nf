process CSQ {
    tag "${params.assembly}:${tool}:${params.version}:${id}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/annotations/${tool}", mode: 'copy')

    input:
    tuple val(id), path(file), path(index), val(tool)

    output:
    tuple val("${params.assembly}"), val("${tool}"), val("${params.version}"), val(id),
          path("${params.assembly}.${tool}.${params.version}.${id}.vcf.gz"),
          path("${params.assembly}.${tool}.${params.version}.${id}.vcf.gz.tbi"),
          env(nvariants)

    script:
    """
    #!/bin/bash
    # Extract missense variants
    bcftools csq --phase a -f ${params.fasta} -g ${params.gff} ${file} | \
    bcftools view --threads ${task.cpus} -Oz -o ${params.assembly}.${tool}.${params.version}.${id}.vcf.gz

    tabix ${params.assembly}.${tool}.${params.version}.${id}.vcf.gz

    nvariants=\$(bcftools index -n ${params.assembly}.${tool}.${params.version}.${id}.vcf.gz)
    """
}
