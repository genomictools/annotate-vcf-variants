### Introduction

This workflow annotates variants using different databases, tools or APIs. 
The output of the workflow is a copy of the input VCF with added annotation
fields.

The workflow is designed to
- Have a unified interface so it can be extende with other tools (VCF in, VCF out)
- Extract unique variants from all input VCF so each variant will be annotated only once
- Split the variants into chunks so that the tools can be run in parallel
  
### Usage

`--cohorts` and `--output_dir` are required inputs. The input to `--cohorts`
is a CSV file with three columns: `cohort,file,index`

The typical command looks like the following. 

```bash
nextflow run genomictools/annotate-vcf-variants/main.nf \
    --output_dir results/ \
    --cohorts cohorts_input.csv
```

### Inputs & Parameters

The workflow currently supports, `tool`: 
  - `vep`
  - `spliceai`
  - `pangolin`
  - `alphagenome`

- when `tool = 'vep'`
  - `species`: Default 'homo_sapiens'
  - `assembly`: Default 'GRCh38'
  - `cadd`: Default false
  - `spliceai`: Default false
  - `gnomad`: Default false

- when `tool = 'spliceai'` or `tool = 'pangolin'`
  - `distance`: Default 50
  - `masked`: Default true

- when `tool = 'alphagenome'`
  - `species`: Default 'homo_sapiens'. 
  - `distance`: Default 50

- `chunk`: Default 10
- `limit`: Default 30

- `normalize`: Default true
- `remove_ambiguous`: Default true
  
### Output

The pipeline consists of three subworkflows that are exucted in order

1. `split_vcf`: extracts variants from the VCF, splits into chunks and convert back to VCF  
2. `run_<tool>`: runs the annotation tool
3. `annotate_vcf`: annotate the original VCF file with the tool output

The final output is a found in `annotated/<cohort>.<species/assembly>.<tool>.<version>.vcf.gz`
and is a copy of the input VCF with annotations.

## Example

A VCF test dataset can be downloaded from [here](https://raw.githubusercontent.com/genomictools/test-datasets/refs/heads/annotate-vcf-variants/pheno.variants.vcf.gz)
 and an index from [here](https://raw.githubusercontent.com/genomictools/test-datasets/refs/heads/annotate-vcf-variants/pheno.variants.vcf.gz.tbi)

1. Create `cohort_info.csv`
```bash
# Create input file
echo "cohort,file,index" > cohort_info.csv
echo "cohort1,pheno.variants.vcf.gz,pheno.variants.vcf.gz.tbi" >> cohort_info.csv
```

2. Create `params.json`
```json
params {
  "cohort_info" : "cohort_info.csv",
  "tool"        : "alphagenome"
  "version"     : "0.1"
  "species"     : "human"
  "distance"    : "1MB"
}
```

3. Run workflow
```bash
# Run workflow
nextflow run annotate-vcf-variants/main.nf \
    --output_dir results/ \
    -profile local \
    -params-file params.json
```

4. Explore output
```bash
# output
$ ls -R results/
# results/extracted:
# cohort1.variants.tsv

# results/variants:
# variants.txt
# variants.unique.txt

# results/converted:
# chunk.1.converted.vcf.gz
# chunk.1.converted.vcf.gz.tbi
# chunk.2.converted.vcf.gz
# chunk.2.converted.vcf.gz.tbi
# chunk.3.converted.vcf.gz
# chunk.3.converted.vcf.gz.tbi

# results/annotations:
# human.alphagenome.0.1.chunk.1.scores.tsv
# human.alphagenome.0.1.chunk.1.scores.vcf.gz
# human.alphagenome.0.1.chunk.1.scores.vcf.gz.tbi
# human.alphagenome.0.1.chunk.2.scores.tsv
# human.alphagenome.0.1.chunk.2.scores.vcf.gz
# human.alphagenome.0.1.chunk.2.scores.vcf.gz.tbi
# human.alphagenome.0.1.chunk.3.scores.tsv
# human.alphagenome.0.1.chunk.3.scores.vcf.gz
# human.alphagenome.0.1.chunk.3.scores.vcf.gz.tbi

# results/concatinated:
# human.alphagenome.0.1.vcf.gz
# human.alphagenome.0.1.vcf.gz.tbi

# results/annotated:
# cohort1.human.alphagenome.0.1.vcf.gz
# cohort1.human.alphagenome.0.1.vcf.gz.tbi

# results/formated:
# cohort1.human.alphagenome.0.1.tsv
```

```bash
# headers
$ diff <(bcftools view -h pheno.variants.vcf.gz) <(bcftools view -h results/annotated/cohort1.human.alphagenome.0.1.vcf.gz)
# > ##INFO=<ID=AlphaGenome,Number=.,Type=String,Description=AlphaGenome predictions. Format: variant_id|scored_interval|gene_id|gene_name|gene_type|gene_strand|junction_Start|junction_End|output_type|variant_scorer|track_name|track_strand|Assay title|ontology_curie|biosample_name|biosample_type|transcription_factor|histone_mark|gtex_tissue|raw_score|quantile_score>
```

```bash
# AlphaGenome tag
$ bcftools query -f '%AlphaGenome\n' results/annotated/cohort1.human.alphagenome.0.1.vcf.gz | head -1 | cut -d ',' -f 1,2 | tr ',' '\n'
# chr1:11030859:C>A|chr1:10506571-11555147:.|.|.|.|.|.|.|ATAC|CenterMaskScorer(requested_output=ATAC/width=501/aggregation_type=DIFF_LOG2_SUM)|CL:0000084_ATAC-seq|.|ATAC-seq|CL:0000084|T-cell|primary_cell|.|.|.|-0.045094967|-0.8940993
# chr1:11030859:C>A|chr1:10506571-11555147:.|.|.|.|.|.|.|ATAC|CenterMaskScorer(requested_output=ATAC/width=501/aggregation_type=DIFF_LOG2_SUM)|CL:0000100_ATAC-seq|.|ATAC-seq|CL:0000100|motor_neuron|in_vitro_differentiated_cells|.|.|.|0.0033369064|0.0691056
```

