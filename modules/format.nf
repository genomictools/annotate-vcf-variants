process FORMAT {
    tag "${cohort}:${assembly}:${tool}:${version}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/formated", mode: 'copy')

    input:
    tuple val(cohort), val(assembly), val(tool), val(version),
          path(file), path(index)

    output:
    tuple val(cohort), val(assembly), val(tool), val(version),
          path("${cohort}.${assembly}.${tool}.${version}.tsv")

    script:
    if ( params.tool == "vep" ) {
        """
        #!/bin/bash
        # Format VEP CSQ to TSV
        echo -e "VARIANT\t\$(bcftools +split-vep -l ${file} | cut -f 2 | tr '\n' '\t' | sed 's/\t\$//')" \
        > ${cohort}.${assembly}.${tool}.${version}.tsv
	    
        bcftools +split-vep \
		-s worst \
		-c Gene \
		-f '%CHROM:%POS:%REF:%ALT\t%CSQ\n' \
		-d -A tab \
		${file} \
		>> ${cohort}.${assembly}.${tool}.${version}.tsv
        """
    } else if ( params.tool == "spliceai" ) {
        """
        #!/bin/bash
        # Format SpliceAI to TSV
        echo -e "VARIANT\tALLELE\tSYMBOL\tDS_AG\tDS_AL\tDS_DG\tDS_DL\tDP_AG\tDP_AL\tDP_DG\tDP_DL" \
        > ${cohort}.${assembly}.${tool}.${version}.tsv
        
        bcftools query -f '%CHROM:%POS:%REF:%ALT;%SpliceAI\n' ${file} | \
        awk -F';' '{
            n = split(\$2, arr, ",")
            for (i = 1; i <= n; i++) {
                print \$1 ";" arr[i]
            }
        }' | \
        tr ';' '\\t' | \
        tr '|' '\\t' \
        >> ${cohort}.${assembly}.${tool}.${version}.tsv
        """
    } else {
        error "Unsupported tool: ${params.tool}"
    }
}
