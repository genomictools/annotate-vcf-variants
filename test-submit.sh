#!/bin/bash

#SBATCH -o tests/tests.out
#SBATCH -e tests/tests.err
#SBATCH -J tests
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Load conda environment
module load Java/17
source $NXF_CONDA

# # Setup tests
# curl -fsSL https://get.nf-test.com | bash
# ./nf-test init
# ./nf-test generate pipeline main.nf

# Download input data
mkdir -p tests tests/input

URL="https://raw.githubusercontent.com/genomictools/test-datasets/refs/heads/annotate-vcf-variants"
wget -c $URL/pheno.variants.vcf.gz -O tests/input/pheno.variants.vcf.gz
wget -c $URL/pheno.variants.vcf.gz.tbi -O tests/input/pheno.variants.vcf.gz.tbi
wget -c $URL/cohort_info.csv -O tests/input/cohort_info.csv

# # Run tests
# ./nf-test test tests/main.nf.test

# # Run nextflow (example)
# nextflow run genomictools/select-cohort-variants -r main \
cd tests/

# nextflow run houlstonlab/annotate-vcf-vep -r v0.1 \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile local,test_alphagenome \
    -params-file ../test-params.json \
    -with-report ./report.html \
    -with-timeline ./timeline.html \
    -resume

# # usage: nextflow run [ local_dir/main.nf | git_url ]  
# # These are the required arguments:
# #     -r            {main,dev,gha} to run specific branch
# #     -profile      {local,cluster} to run using differens resources
# #     -params-file  params.json to pass parameters to the pipeline
# #     -resume       To resume the pipeline from the last checkpoint
