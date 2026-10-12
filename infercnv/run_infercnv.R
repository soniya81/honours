library(infercnv)
library(Seurat)

out_dir <- "/scratch/temp/27798493/infercnv/AML5_DX/results" #change per attempt and/or sample
dir.create(out_dir, showWarnings = FALSE)

print(time)

infercnv_obj <- CreateInfercnvObject(
  raw_counts_matrix = "/scratch/temp/27798493/infercnv/AML5_DX/infercnv_input/AML5_DX_raw_counts_matrix.txt",  # or .txt with delim="\t"
  annotations_file = "/scratch/temp/27798493/infercnv/AML5_DX/infercnv_input/AML5_DX_annotations_file.txt",
  delim = "\t",  # or "," if using CSV
  gene_order_file = "/scratch/user/s4881477/projects/infercnv/inferCNV_examples/__gene_position_data/gencode_v19_gene_pos.txt",
  ref_group_names = c("Normal")  # <-- REPLACE with your reference cell group name
)

print("PASS 1:  created infercnvObject successfully!!!")

#pdf(file = file.path(out_dir, "infercnv_run_plots.pdf"), width = 16, height = 10)

graphics.off()

options(bitmapType = 'cairo')

pdf(file = file.path(out_dir, "infercnv_final_massive_plot.pdf"), width = 30, height = 24)

par(mar = c(0.01, 0.01, 0.01, 0.01), oma = c(0, 0, 0, 0)) # Drop margins to absolute minimum

infercnv_obj_final = run(
   infercnv_obj,
   cutoff=0.1, # cutoff=1 works well for Smart-seq2, and cutoff=0.1 works well for 10x Genomics
   out_dir= out_dir,
   cluster_by_groups=TRUE,
   plot_steps=FALSE,
   denoise=TRUE,
   leiden_resolution = 0.5, ##default = 0.5, improves better subclustering resol
   BayesMaxPNormal = 0.5, ##default = 0.5, improves filtering
   HMM=TRUE,
   no_plot = TRUE,
   no_prelim_plot = TRUE,
   output_format = NA,
   num_threads = 50
)

print(time)

print("3. Explicitly plot the final object manually using the massive canvas")
infercnv::plot_cnv(
   infercnv_obj_final,
   out_dir = out_dir,
   output_format = "pdf",
   title = "InferCNV Final Heatmap"
)


dev.off()

print("PASS 2:  completed running infercnv successfully!!!")
