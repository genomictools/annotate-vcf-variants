process INDEX {
    tag "${cohort}:${assembly}:${version}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/annotated/", mode: 'copy')

    input:
    tuple val(cohort), val(assembly), val(version),
          path(vcf), path(log)

    output:
    tuple val(cohort), val(assembly), val(version),
          path(vcf), 
          path("${cohort}.${assembly}.${version}.vcf.gz.tbi"),
          path(log)

    script:
	"""
    #!/bin/bash
    tabix -p vcf ${vcf}
    """
}
