process CONVERT {
    tag "${id}"

    label 'simple'
    label 'bcftools'


    publishDir("${params.output_dir}/converted", mode: 'copy')

    input:
    tuple val(id), path(file)

    output:
    tuple val(id),
          path("${id}.converted.vcf.gz"),
          path("${id}.converted.vcf.gz.tbi")

    script:
    """
    #!/bin/bash
    # Create site-only VCF
    bcftools convert \
        -c CHROM,POS,REF,ALT,ID,TYPE \
        -f ${params.fasta} \
        --tsv2vcf ${file} \
        --threads ${task.cpus} \
        -Oz -o ${id}.converted.vcf.gz
    tabix ${id}.converted.vcf.gz
    """
}
