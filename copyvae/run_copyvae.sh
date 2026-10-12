#!/usr/bin/env bash
#SBATCH --job-name=copyvae_%a
#SBATCH --account=a_chrc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100G
#SBATCH --time=48:00:00
#SBATCH --partition=general
#SBATCH --array=1-72%10
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

set -euo pipefail

mkdir -p "/$TMPDIR/copyvae/"
mkdir -p "/$TMPDIR/copyvae/AML5_DX"
cd "/$TMPDIR/copyvae/AML5_DX"

echo "activating conda environment"
source "/home/s4881477/miniconda3/etc/profile.d/conda.sh"
conda activate copyvae

export PYTHONPATH="${PYTHONPATH:-}:/scratch/user/s4881477/projects"

/home/s4881477/miniconda3/envs/copyvae/bin/python3 "/$TMPDIR/copyvae/cvae_array.py" \
    --h5ad "/QRISdata/Q5935/data/Lambo/h5ad/updated_AML5_DX_raw.h5ad" \
    --cell_cycle_gene_list "/scratch/user/s4881477/projects/copyvae/data/Macosko_cell_cycle_genes.txt" \
    --outdir "/$TMPDIR/copyvae/AML5_DX"

