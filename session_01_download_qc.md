"""
Script 01 — Run BUSCO on all Prevotella copri genome assemblies
================================================================
This script finds all .fna genome files inside the NCBI download folder,
runs BUSCO on each one using the bacteria_odb10 database, and saves
the completeness results.

What is BUSCO?
BUSCO (Benchmarking Universal Single-Copy Orthologs) checks how complete
a genome assembly is by looking for genes that should be present in every
bacterium. If 95%+ of these genes are found → the genome is high quality.

Usage:
    python3 01_run_busco.py

Requirements:
    - BUSCO v5 installed (conda install -c conda-forge -c bioconda busco)
    - bacteria_odb10 database downloaded automatically by BUSCO
"""

import os
import re
import glob
import subprocess
import time

# ---------------------------------------------------------------
# CONFIGURATION — change these paths to match your system
# ---------------------------------------------------------------
GCA_PATH   = "/home/palan/prevotella_genomes/ncbi_dataset/data/GCA_folder"
OUTPUT_CSV = "/home/palan/prevotella_genomes/busco_results_all.csv"
CPU        = "2"       # number of CPU cores per BUSCO run
SLEEP_TIME = 10        # seconds to wait between runs (reduces system load)

# ---------------------------------------------------------------
# FIND ALL GENOME FILES
# ---------------------------------------------------------------
# glob.glob with recursive=True searches all subfolders
# Pattern: any file ending in _genomic.fna inside any subfolder
genome_files = glob.glob(GCA_PATH + "/**/*_genomic.fna", recursive=True)
total = len(genome_files)
print(f"TOTAL GENOMES FOUND = {total}")

# ---------------------------------------------------------------
# RUN BUSCO ON EACH GENOME
# ---------------------------------------------------------------
results = []

for i, genome in enumerate(genome_files, start=1):

    genome_id   = os.path.basename(genome)
    percent     = round((i / total) * 100, 2)
    out_folder  = f"busco_{genome_id}"

    print(f"\n[{i}/{total}] ({percent}%) Running BUSCO on: {genome_id}")

    # Build the BUSCO command
    # -i  : input genome file
    # -l  : lineage database (bacteria_odb10 for all bacteria)
    # -o  : output folder name
    # -m  : mode (genome = we are analysing a genome assembly)
    # --cpu: number of CPU cores to use
    cmd = [
        "busco",
        "-i",    genome,
        "-l",    "bacteria_odb10",
        "-o",    out_folder,
        "-m",    "genome",
        "--cpu", CPU
    ]

    try:
        subprocess.run(cmd, check=True)
    except Exception as e:
        print(f"  BUSCO FAILED for {genome_id}: {e}")
        continue

    # ---------------------------------------------------------------
    # FIND AND PARSE THE BUSCO SUMMARY FILE
    # ---------------------------------------------------------------
    # BUSCO saves a short_summary file with the completeness scores
    summary_files = glob.glob(f"{out_folder}/run_*/short_summary*.txt")

    if not summary_files:
        print(f"  No summary file found for {genome_id}")
        continue

    with open(summary_files[0]) as f:
        text = f.read()

    # Extract the BUSCO score line using regex
    # The line looks like: C:98.4%[S:97.6%,D:0.8%],F:0.8%,M:0.8%,n:124
    # C = Complete, S = Single copy, D = Duplicated
    # F = Fragmented, M = Missing, n = total BUSCOs checked
    match = re.search(
        r"C:(\d+\.?\d*)%\[S:(\d+\.?\d*)%,D:(\d+\.?\d*)%\],"
        r"F:(\d+\.?\d*)%,M:(\d+\.?\d*)%,n:(\d+)",
        text
    )

    if not match:
        print(f"  Cannot parse BUSCO result for {genome_id}")
        continue

    C, S, D, F, M, n = match.groups()

    print(f"  Complete: {C}% | Single: {S}% | Dup: {D}% | "
          f"Frag: {F}% | Missing: {M}% | Total BUSCOs: {n}")

    results.append({
        "Genome":       genome_id,
        "Complete":     float(C),
        "Single_copy":  float(S),
        "Duplicated":   float(D),
        "Fragmented":   float(F),
        "Missing":      float(M),
        "Total_BUSCOs": int(n)
    })

    time.sleep(SLEEP_TIME)

# ---------------------------------------------------------------
# SAVE ALL RESULTS TO CSV
# ---------------------------------------------------------------
import csv

with open(OUTPUT_CSV, "w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=["Genome","Complete","Single_copy",
                    "Duplicated","Fragmented","Missing","Total_BUSCOs"]
    )
    writer.writeheader()
    writer.writerows(results)

print(f"\nALL BUSCO RUNS FINISHED")
print(f"Results saved to: {OUTPUT_CSV}")
print(f"Total genomes processed: {len(results)} / {total}")
