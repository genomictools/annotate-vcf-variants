process CONCATINATE {
    tag "${assembly}:${tool}:${version}"

    label 'simple'
    label 'bcftools'


    publishDir("${params.output_dir}/concatinated/", mode: 'copy')

    input:
    tuple val(assembly), val(tool), val(version), 
          val(id), path(file), path(index)

    output:
    tuple val(assembly), val(tool), val(version), 
          path("${assembly}.${tool}.${version}.vcf.gz"),
          path("${assembly}.${tool}.${version}.vcf.gz.tbi")

    script:
    """
    #!/bin/bash
    # Combine vcfs
    bcftools concat \
        -f <(echo "${file.join('\n')}" | sort -V) \
        --naive \
        --threads ${task.cpus} \
        -Oz -o ${assembly}.${tool}.${version}.vcf.gz

    tabix ${assembly}.${tool}.${version}.vcf.gz
    """
}
