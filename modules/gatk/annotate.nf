process ANNOTATE {
    tag "${cohort}:${assembly}:${version}"

    label 'simple'
    label 'gatk'

    publishDir("${params.output_dir}/annotated/", mode: 'copy')

    input:
    tuple val(cohort), path(vcf), path(vcf_index),
          val(assembly), val(tool), val(version),
          path(anno_vcf), path(anno_index),
          val(nvariants)

    output:
    tuple val(cohort), val(assembly), val(version),
          path("${cohort}.${assembly}.${version}.vcf.gz"),
        //   path("${cohort}.${assembly}.${version}.vcf.gz.tbi"),
          path("${cohort}.${assembly}.${version}.log")

    script:
    def args = []
    // If tool and anno_vcf are lists, zip them together:
    ( tool instanceof List ? tool : [tool] ).withIndex().each { t, i ->
        def vcf = (anno_vcf instanceof List ? anno_vcf : [anno_vcf])[i]
        args << "--resource:${t} ${vcf} --expression ${t}.${t}"
    }
    def args_str = args.join(' ')

	"""
    #!/bin/bash
    gatk VariantAnnotator \
        -R ${params.fasta} \
        -V ${vcf} \
        --output ${cohort}.${assembly}.${version}.vcf.gz \
        ${args_str} \
        2> ${cohort}.${assembly}.${version}.log
    """
}
