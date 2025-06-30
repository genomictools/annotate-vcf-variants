process ANNOTATE {
    tag "${cohort}:${assembly}:${tool}:${version}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/annotated/", mode: 'copy')

    input:
    tuple val(assembly), val(tool), val(version), path(anno_file), path(anno_index),
          val(cohort), path(vcf), path(vcf_index)

    output:
    tuple val(cohort), val(assembly), val(tool), val(version),
          path("${cohort}.${assembly}.${tool}.${version}.vcf.gz"),
          path("${cohort}.${assembly}.${tool}.${version}.vcf.gz.tbi")

    script:
    def tag = ''
    if ( params.tool  == "vep")      { tag < "CSQ" }
    if ( params.tool  == "spliceai") { tag < "SpliceAI" }
    """
    #!/bin/bash
    # Rename and annotate
    bcftools annotate -a ${anno_file} -c INFO -h <(bcftools view -h ${anno_file} | grep ${tag}) ${vcf} | \
    bcftools view --threads ${task.cpus} -Oz -o ${cohort}.${assembly}.${tool}.${version}.vcf.gz
    tabix ${cohort}.${assembly}.${tool}.${version}.vcf.gz
    """
}
