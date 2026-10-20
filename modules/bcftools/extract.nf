process EXTRACT {
    tag "${cohort}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/extracted", mode: 'copy')

    input:
    tuple val(cohort), val(file), path(index)

    output:
    tuple val(cohort), path("${cohort}.variants.tsv")

    script:
    """
    # Extract variants
    bcftools view ${file} | \
    if [ ${params.normalize} ];        then bcftools norm -m -any; fi | \
    if [ ${params.remove_ambiguous} ]; then bcftools view -e 'ALT="*"' ; fi | \
	bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%ID\t%TYPE\n' > ${cohort}.variants.tsv
    """
}

