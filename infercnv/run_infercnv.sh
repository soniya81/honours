#!/bin/bash

#SBATCH --job-name=infercnv_AML3_DX
#SBATCH --account=a_chrc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=256G
#SBATCH --time=48:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

mkdir -p /$TMPDIR/infercnv/AML5_DX
cd /$TMPDIR/infercnv/AML5_DX
pwd

echo "activating conda environments"

#activate conda env
source "/home/s4881477/miniconda3/etc/profile.d/conda.sh"
conda activate infercnv_final

echo "successfully activated conda, now starting R script"

#produce matrix
Rscript /$TMPDIR/infercnv/infercnv_input.R

#Run r file
Rscript /$TMPDIR/infercnv/run_infercnv.R

echo "successfully completed Rscript, now exiting"

exit