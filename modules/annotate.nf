process ANNOTATE {
    tag "${cohort}:${assembly}:${tool}:${version}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/annotated/", mode: 'copy')

    input:
    tuple val(assembly), val(tool), val(version), path(anno_file), path(anno_index),
          val(cohort), path(vcf), path(vcf_index)

    output:
    tuple val(cohort), val(version), val(assembly), val(tool), val(version),
          path("${cohort}.${assembly}.${tool}.${version}.vcf.gz"),
          path("${cohort}.${assembly}.${tool}.${version}.vcf.gz.tbi")

    script:
    """
    #!/bin/bash
    # Rename and annotate
    bcftools annotate -a ${anno_file} -c INFO -h <(bcftools view -h ${anno_file} | grep CSQ) ${vcf} | \
    bcftools view --threads ${task.cpus} -Oz -o ${cohort}.${assembly}.${tool}.${version}.vcf.gz
    tabix ${cohort}.${assembly}.${tool}.${version}.vcf.gz
    """
}
