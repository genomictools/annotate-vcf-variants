#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include subworkflow
include { split_vcf }       from './subworkflows/split_vcf.nf'
include { run_tool }        from './subworkflows/run_tool.nf'
include { annotate_vcf }    from './subworkflows/annotate_vcf.nf'

tools_ch = Channel.from( params.tools.split(',') )

// Workflow
workflow {
    // Define input from file
    cohort_info_ch = Channel.fromPath(params.cohort_info)
        | splitCsv(header: true, sep: ',')
        | map { row -> [ row.cohort, file(row.file), file(row.index) ]}

    variants      = split_vcf(cohort_info_ch)
    annotations   = run_tool(variants, tools_ch)
    annotated_vcf = annotate_vcf(cohort_info_ch, annotations)
}
