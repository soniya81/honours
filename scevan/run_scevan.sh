#!/bin/bash
#SBATCH --job-name=AML5_DX
#SBATCH --account=a_chrc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=256G
#SBATCH --time=168:00:00
#SBATCH --partition=general
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

cd /$TMPDIR/scevan
mkdir -p /$TMPDIR/scevan/AML5_DX
cd /$TMPDIR/scevan/AML5_DX
pwd

PROOT_NO_SECCOMP=1 apptainer build --force --sandbox /$TMPDIR/scevan_sandbox docker://anthonyphis/r_scevan:latest

 apptainer exec \
  --bind /scratch/user/s4881477/projects/scevan:/mnt/mydata \
  --bind /scratch/user/s4881477/projects/scevan/lambo_rawcounts:/scratch/user/s4881477/projects/scevan/lambo_rawcounts \
  /$TMPDIR/scevan_sandbox \
  Rscript /$TMPDIR/scevan/run_scevan.R

mkdir -p /QRISdata/Q9676/scevan_results_Aug_2026/AML5_DX

rsync -azvhP /$TMPDIR/scevan/AML5_DX/*.csv /QRISdata/Q9676/scevan_results_Aug_2026/AML5_DX
rsync -azvhP /$TMPDIR/scevan/AML5_DX/output/ /QRISdata/Q9676/scevan_results_Aug_2026/AML5_DX

