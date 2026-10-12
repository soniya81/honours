#!/bin/bash

#SBATCH --job-name=cKAT3_test
#SBATCH --account=a_chrc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100G
#SBATCH --time=03:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "activating conda environments"
mkdir -p /$TMPDIR/copykat/AML5_DX
cd /$TMPDIR/copykat/AML5_DX
pwd

#activate conda env
source "/home/s4881477/miniconda3/etc/profile.d/conda.sh"
conda activate copykat

echo "successfully activated conda, now starting copykat script"

Rscript /$TMPDIR/copykat/run_copykat.R

echo "successfully completed R script, now exiting"

exit
