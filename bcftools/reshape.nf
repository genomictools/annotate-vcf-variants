process RESHAPE {
    tag "${params.species}:${tool}:${params.version}:${id}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/annotations/${tool}", mode: 'copy')

    input:
    tuple val(assembly), val(tool), val(version), val(id),
		  path(file), path(index),
		  val(nvariants)

    output:
    tuple val(assembly), val(tool), val(version), val(id),
          path("${assembly}.${tool}.${version}.${id}.annotated.vcf.gz"),
          path("${assembly}.${tool}.${version}.${id}.annotated.vcf.gz.tbi"),
		  env(nvariants)

    script:
    """
    #!/bin/bash
	# Convert to VCF format
	bcftools convert \
		--tsv2vcf ${file} \
		-c CHROM,POS,ID,REF,ALT \
		-f ${params.fasta} | \
	bcftools annotate \
		-a ${file} \
		-c CHROM,POS,ID,REF,ALT,${tool} \
		-h <(zcat ${file} | head -1) \
		--merge-logic ${tool}:unique \
		--threads ${task.cpus} \
		-Oz -o ${assembly}.${tool}.${version}.${id}.annotated.vcf.gz

	tabix ${assembly}.${tool}.${version}.${id}.annotated.vcf.gz

	nvariants=\$(bcftools index -n ${assembly}.${tool}.${version}.${id}.annotated.vcf.gz)
    """
}
