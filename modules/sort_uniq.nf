process SORT_UNIQ {
    publishDir("${params.output_dir}/variants", mode: 'copy')

    input:
    path variants_file

    output:
    path "${variants_file.simpleName}.unique.txt"

    script:
    """
    cat ${variants_file} | sort -Vu > ${variants_file.simpleName}.unique.txt
    """
}
