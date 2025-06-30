#!/bin/bash

#SBATCH -o test/test.out
#SBATCH -e test/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p test/ test/input
cd test/

# Download test data
URL="https://figshare.com/ndownloader/files"

wget -c $URL/50487621 -O input/pheno.variants.vcf.gz
wget -c $URL/50487624 -O input/pheno.variants.vcf.gz.tbi

echo "cohort,file,index" > input/cohort_info.csv
echo "cohort1,input/pheno.variants.vcf.gz,input/pheno.variants.vcf.gz.tbi" >> input/cohort_info.csv

# Clean previous runs
# rm -rf results/ work/ .nextflow*
rm ./test.* ./*.html

# Run nextflow
module load Nextflow

# nextflow run houlstonlab/annotate-vcf-vep -r v0.1 \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile cluster,test_vep \
    -params-file ../test-params.json \
    -with-report ./report.html \
    -with-timeline ./timeline.html \
    -resume

# usage: nextflow run [ local_dir/main.nf | git_url ]  
# These are the required arguments:
#     -r            {main,dev,gha} to run specific branch
#     -profile      {local,cluster} to run using differens resources
#     -params-file  params.json to pass parameters to the pipeline
#     -resume       To resume the pipeline from the last checkpoint
