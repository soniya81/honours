print(time)

count_mtx <- read.csv("/scratch/user/s4881477/projects/scevan/lambo_rawcounts/AML5_DX_raw_counts.csv")
count_mtx <- t(count_mtx)

library(SCEVAN)
result <- pipelineCNA(count_mtx, SUBCLONES = FALSE, par_cores = 20)

print(time)

head(result)
colnames(result)
table(result$class)

write.csv(result, "AML5_DX_scevan_predictions.csv")
q()

