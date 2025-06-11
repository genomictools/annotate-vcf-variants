#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include subworkflow
include { annotate_vcf_vep }    from './subworkflows/annotate_vcf_vep.nf'

// Workflow
workflow {
    // Define input from file
    cohort_info_ch = Channel.fromPath(params.cohort_info)
        | splitCsv(header: true, sep: ',')
        | map { row -> [ row.cohort, file(row.file), file(row.index) ]}

    annotate_vcf_vep(cohort_info_ch)
}
