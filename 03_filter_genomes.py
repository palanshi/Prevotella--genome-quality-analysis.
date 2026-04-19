#!/bin/bash
# =============================================================
# Script 02 — Run CheckM on all Prevotella copri genomes
# =============================================================
# CheckM analyses genome quality by checking:
#   - Genome size (is it in the expected range?)
#   - GC content (does it match Prevotella copri ~45%?)
#   - Number of contigs (fewer = better assembly)
#   - N50 (how long are the assembled pieces? higher = better)
#   - Predicted genes (how many protein-coding genes found?)
#
# What is CheckM doing differently from BUSCO?
#   BUSCO checks: "are the right genes present?"
#   CheckM checks: "do the genome statistics look correct?"
#   Together they give a complete picture of genome quality.
#
# Usage:
#   bash 02_run_checkm.sh
#
# Requirements:
#   - CheckM installed: pip install checkm-genome
#   - Run: checkm data setRoot /path/to/checkm/database
# =============================================================

# ---------------------------------------------------------------
# CONFIGURATION — change these paths to match your system
# ---------------------------------------------------------------

# Folder containing all your genome .fna files
GENOME_DIR="/home/palan/prevotella_genomes/ncbi_dataset/data"

# Folder where CheckM will save its output
OUTPUT_DIR="/home/palan/prevotella_genomes/checkm_output"

# Final summary file — this is what becomes checkm_summary.csv
SUMMARY_FILE="/home/palan/prevotella_genomes/checkm_summary.csv"

# Number of CPU cores to use
THREADS=4

# ---------------------------------------------------------------
# CREATE OUTPUT DIRECTORY IF IT DOES NOT EXIST
# ---------------------------------------------------------------
mkdir -p "$OUTPUT_DIR"

# ---------------------------------------------------------------
# RUN CHECKM
# ---------------------------------------------------------------
# lineage_wf  = the full workflow (lineage-specific marker genes)
#               This is the most accurate mode for bacteria
# $GENOME_DIR = folder containing all genome .fna files
# $OUTPUT_DIR = where CheckM saves its working files
# -x fna      = file extension of your genome files
# --tab_table = save results as a tab-separated table
# -f          = output file name for the summary
# --threads   = number of CPU cores to use

echo "Starting CheckM analysis..."
echo "Genome folder: $GENOME_DIR"
echo "Output folder: $OUTPUT_DIR"
echo "Summary file:  $SUMMARY_FILE"
echo ""

checkm lineage_wf \
    "$GENOME_DIR" \
    "$OUTPUT_DIR" \
    -x fna \
    --tab_table \
    -f "$SUMMARY_FILE" \
    --threads $THREADS

echo ""
echo "CheckM complete!"
echo "Results saved to: $SUMMARY_FILE"
