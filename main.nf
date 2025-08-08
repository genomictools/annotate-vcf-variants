#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include subworkflow
include { split_vcf }       from './subworkflows/split_vcf.nf'
include { run_vep }         from './subworkflows/run_vep.nf'
include { run_spliceai }    from './subworkflows/run_spliceai.nf'
include { run_alphagenome } from './subworkflows/run_alphagenome.nf'
include { run_atsnp }       from './subworkflows/run_atsnp.nf'
include { annotate_vcf }    from './subworkflows/annotate_vcf.nf'

// Workflow
workflow {
    // Define input from file
    cohort_info_ch = Channel.fromPath(params.cohort_info)
        | splitCsv(header: true, sep: ',')
        | map { row -> [ row.cohort, file(row.file), file(row.index) ]}

    variants      = split_vcf(cohort_info_ch)
    if ( params.tool == 'vep' ) {
        annotations   = run_vep(variants)
    } else if ( params.tool == 'spliceai' ) {
        annotations   = run_spliceai(variants)
    } else if ( params.tool == 'pangolin' ) {
        annotations   = run_pangolin(variants)
    } else if ( params.tool == 'alphagenome' ) {
        annotations   = run_alphagenome(variants)
    } else if ( params.tool == 'atsnp' ) {
        annotations   = run_atsnp(variants)
    } else {
        error "Unsupported tool: ${params.tool}"
    }
    annotated_vcf = annotate_vcf(cohort_info_ch, annotations)
}
