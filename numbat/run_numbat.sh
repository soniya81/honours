#!/bin/bash
#SBATCH --job-name=8_numbat
#SBATCH --account=a_chrc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=256G
#SBATCH --time=168:00:00
#SBATCH --partition=general
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

mkdir -p logs
mkdir -p "/$TMPDIR/numbat/AML5_DX"

cd "/$TMPDIR/numbat/AML5_DX"

pwd

rsync -azvhP /QRISdata/Q9676/lambo_cellranger_out/AML5_DX/ "/$TMPDIR/numbat/AML5_DX"

echo '1) installing docker onto /$TMPDIR'
PROOT_NO_SECCOMP=1 apptainer build --sandbox /$TMPDIR/numbat_sandbox docker://pkharchenkolab/numbat-rbase:latest 

apptainer exec \
  --bind /scratch/user/s4881477/projects/numbat:/mnt/mydata \
  /$TMPDIR/numbat_sandbox \
  Rscript /mnt/mydata/numbat/inst/bin/pileup_and_phase.R \
    --label AML5_DX \
    --samples AML5_DX \
    --bams /$TMPDIR/numbat/AML5_DX/possorted_genome_bam.bam \
    --barcodes /$TMPDIR/numbat/AML5_DX/filtered_feature_bc_matrix/barcodes.tsv.gz \
    --gmap /Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz \
    --snpvcf /data/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf \
    --paneldir /data/1000G_hg38 \
    --ncores 8 \
    --cellTAG CB \
    --UMItag Auto,None \
    --outdir /$TMPDIR/numbat/AML5_DX/numbat_out


echo '2) pileup and phase done'

rsync -azvhP /$TMPDIR/numbat/AML5_DX/* allele_counts.tsv.gz /QRISdata/Q9676/numbat_results/AML5_DX/

echo '3) allele counts obtained, starting run_numbat()'

ls

apptainer exec \
  --bind //$TMPDIR/numbat/AML5_DX:/out \
  --bind /QRISdata/Q5935/data/Lambo/h5ad:/data \
  --bind /QRISdata/Q9676 \
  --bind /scratch/user/s4881477/projects/numbat:/mnt/mydata \
  //$TMPDIR/numbat_sandbox \
  Rscript /$TMPDIR/run_numbat.R

#mkdir -p /QRISdata/Q9676/numbat_results/AML5_DX
rsync -avhP /$TMPDIR/AML5_DX/numbat_results/ /QRISdata/Q9676/numbat_results/AML5_DX/

echo '4) numbat fully ran, now exiting'

exit

#apptainer exec \
#  --bind /$TMPDIR/numbat/AML5_DX:/out \
#  --bind /QRISdata/Q5935/data/Lambo/h5ad:/data \
#  --bind /QRISdata/Q5935/norman/data/healthy_reference:/ref \
#  --bind /scratch/user/s4881477/projects/numbat:/mnt/mydata \
#  docker://pkharchenkolab/numbat-rbase:latest \
#  Rscript /out/figures.R

# rsync -avhP /$TMPDIR/AML5_DX/numbat_out/ /QRISdata/Q9676/numbat_results/AML5_DX/



