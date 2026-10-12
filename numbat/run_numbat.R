ptions(repos = c(CRAN = "https://cloud.r-project.org"))

r_user_lib <- Sys.getenv("R_LIBS_USER")
if (nzchar(r_user_lib)) {
  dir.create(r_user_lib, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(r_user_lib, .libPaths()))
}

needed <- c("anndata", "reticulate")
to_install <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]

if (length(to_install) > 0) {
  install.packages(to_install, repos = "https://cloud.r-project.org")
}

library(anndata)
library(data.table)

print("1) converting raw h5ad -> count matrix")
ad <- read_h5ad("/data/updated_AML8_DX_raw.h5ad")
count_mat<- ad$layers[["counts"]]
count_mat <- as.matrix(count_mat)
count_mat <- t(count_mat)

print(paste0("dimensions of matrix:", dim(count_mat)))
print(paste0("rownames of matrix:", head(rownames(count_mat))))
print(paste0("colnames of matrix:", head(colnames(count_mat))))
print(paste0("count_mat succesfully made !!"))

print("2) loading allele counts as a data frame")

df_allele <- fread("/out/AML8_DX_allele_counts.tsv.gz")
print(paste0("checking data frame:", class(df_allele)))
print(paste0("dimension of data frame:", dim(df_allele)))

print("2) allele counts sucessfully loaded !!")

print("3) loading raw .h5ad Pan-Fetal Immune (healthy) as reference ")
ref_path <- "/QRISdata/Q9676/ref_panfetal.rds"
lambdas_ref_agg  <- readRDS(ref_path)

class(lambdas_ref_agg)
dim(lambdas_ref_agg)

print(paste0(dim(lambdas_ref_agg)))
print(paste0((head(rownames(lambdas_ref_agg)))))
print(paste0((head(colnames(lambdas_ref_agg)))))
print("3) healthy ref aggregated loaded")

common_genes <- intersect(rownames(count_mat), rownames(lambdas_ref_agg))
count_mat <- count_mat[common_genes, , drop = FALSE]
lambdas_ref_agg <- lambdas_ref_agg[common_genes, , drop = FALSE]

common_cells <- intersect(colnames(count_mat), unique(df_allele$cell))
count_mat <- count_mat[, common_cells, drop = FALSE]
df_allele <- df_allele[df_allele$cell %in% common_cells, ]

print('4) count matrix, allele counts, and healthy ref loaded ! starting run_numbat')

out_dir <- "/out/numbat_results"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)


library(numbat)

out <- run_numbat(
  count_mat = count_mat,
  lambdas_ref = lambdas_ref_agg,
  df_allele = df_allele,
  genome = "hg38",
  t = 1e-5,
  ncores = 8,
  plot = TRUE,
  out_dir = out_dir
)

print('5) job completed ! moving results to RDM')