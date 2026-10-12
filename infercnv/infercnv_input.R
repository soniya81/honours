library(anndata)

ad <- read_h5ad("/QRISdata/Q5935/data/Lambo/h5ad/updated_AML5_DX_raw.h5ad")

exprs <- t(as.matrix(ad$X))
colnames(exprs) <- ad$obs_names
rownames(exprs) <- ad$var_names

cell_metadata <- ad$obs

out_dir <- "/$TMPDIR/AML5_DX/infercnv_input/"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

raw <- as.data.frame(exprs)
raw <- cbind(Gene = make.unique(rownames(raw)), raw)

write.table(
  raw,
  "/$TMPDIR/AML5_DX/infercnv_input/AML5_DX_raw_counts_matrix.txt",
  sep = "\t", quote = FALSE,
  row.names = FALSE, col.names = TRUE
)

annotations_df <- data.frame(
  cell_id = colnames(exprs),
  group = as.character(cell_metadata[colnames(exprs), "Malignant"]),
  stringsAsFactors = FALSE
)

write.table(
  annotations_df,
  "/$TMPDIR/AML5_DX/infercnv_input/AML5_DX_annotations_file.txt",
  sep = "\t", quote = FALSE,
  row.names = FALSE, col.names = FALSE
)

all(colnames(exprs) %in% annotations_df$cell_id)
all(annotations_df$cell_id %in% colnames(exprs))
