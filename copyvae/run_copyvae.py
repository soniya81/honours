import os
import time
import threading
import psutil
import pandas as pd
from datetime import datetime

import argparse
import os
import sys

import scanpy as sc
import matplotlib.pyplot as plt

from copyvae.pipeline import run_pipeline

# -----------------
# Memory monitor
# -----------------

process = psutil.Process(os.getpid())

peak_memory_bytes = 0
monitoring = True


def monitor_memory():
    global peak_memory_bytes

    while monitoring:
        try:
            memory = process.memory_info().rss

            if memory > peak_memory_bytes:
                peak_memory_bytes = memory

        except psutil.Error:
            pass

        # Check memory every 0.1 second
        time.sleep(0.1)


# --------------------
# Start monitoring
# --------------------
start_time = time.time()
start_datetime = datetime.now()

monitor_thread = threading.Thread(
    target=monitor_memory,
    daemon=True
)

monitor_thread.start()

# ------------------
# copyvae script
# ------------------
print("1) Running CopyVAE pipeline")
adata = run_pipeline(
    umi_counts=h5ad_path,
    cell_cycle_gene_list=cell_cycle_gene_list,
    )

print("2) Pipeline completed, saving outputs")

    # Save full AnnData with CopyVAE results
#    adata_clean = adata.copy()
#   if "if_mt" in adata_clean.var.columns:
#     adata_clean.var = adata_clean.var.drop(columns=["if_mt"])

#   adata_clean.write_h5ad(adata_path)

    # Save a summary CSV if prediction info is available
if "copyvae_prediction" in adata.obs.columns:
    pred_df = adata.obs[["copyvae_prediction"]].copy()
    pred_df["cell"] = adata.obs_names
    pred_df = pred_df.reset_index(drop=True)
    csv_path = os.path.join(outdir, "copyvae_predictions.csv")
    pred_df.to_csv(csv_path, index=False)
    print(f"Saved predictions to {csv_path}")
else:
    print("No 'copyvae_prediction' column found in obs; skipping prediction CSV")


# ------------------------------------------------------------
# Stop monitoring
# ------------------------------------------------------------

end_time = time.time()
end_datetime = datetime.now()

monitoring = False
monitor_thread.join(timeout=1)

# ------------------------------------------------------------
# Calculate metrics
# ------------------------------------------------------------

runtime_seconds = end_time - start_time
runtime_minutes = runtime_seconds / 60

peak_memory_mb = peak_memory_bytes / (1024 ** 2)
peak_memory_gb = peak_memory_bytes / (1024 ** 3)

# ------------------------------------------------------------
# Save results
# ------------------------------------------------------------
metrics = pd.DataFrame({
    "Start_time": [start_datetime],
    "End_time": [end_datetime],
    "Runtime_seconds": [runtime_seconds],
    "Runtime_minutes": [runtime_minutes],
    "Peak_Memory_MB": [peak_memory_mb],
    "Peak_Memory_GB": [peak_memory_gb]
})

metrics.to_csv(
    os.path.join(output_dir, "runtime_memory.csv"),
    index=False
)

# Human-readable output
with open(
    os.path.join(output_dir, "runtime_memory.txt"),
    "w"
) as f:

    f.write(f"Start time: {start_datetime}\n")
    f.write(f"End time: {end_datetime}\n")
    f.write(f"Runtime (seconds): {runtime_seconds:.3f}\n")
    f.write(f"Runtime (minutes): {runtime_minutes:.3f}\n")
    f.write(f"Peak memory (MB): {peak_memory_mb:.2f}\n")
    f.write(f"Peak memory (GB): {peak_memory_gb:.3f}\n")

print(metrics)