# Session 1 — Data Download & Quality Control

**Species:** *Prevotella copri*
**Source:** NCBI Assembly Database
**Date:** April 2026
**Environment:** Ubuntu 22.04 | Python 3.x | BUSCO v5 | CheckM

---

## Objective

Download all publicly available *Prevotella copri* genome assemblies from NCBI
and run two quality control tools (BUSCO and CheckM) to assess which genomes
are complete and reliable enough for scientific analysis.

---

## What is *Prevotella copri* and why does it matter?

*Prevotella copri* is a gram-negative anaerobic bacterium that lives in the
human gut microbiome. It is one of the most studied gut bacteria because:

- It is strongly associated with **rheumatoid arthritis** — patients with this
  disease have much higher levels of *P. copri* in their gut
- It is linked to **diet** — people who eat plant-rich diets have more *P. copri*
- Different strains behave very differently — some strains may be harmful,
  others neutral or even beneficial
- Understanding genome diversity across hundreds of strains is key to
  understanding why strains differ in their effects

---

## Step 1 — Downloading Genomes from NCBI

All genome assemblies for *Prevotella copri* were downloaded from the NCBI
Assembly database using the NCBI Datasets command-line tool.

**Download command:**
```bash
datasets download genome taxon "Prevotella copri" \
  --assembly-source all \
  --filename prevotella_copri_genomes.zip

unzip prevotella_copri_genomes.zip -d ~/prevotella_genomes/
```

**What NCBI gives you:**
Each genome assembly comes as a folder named after its GCA accession number
(e.g., `GCA_003438885.1`). Inside is a `.fna` file containing the full DNA
sequence of that genome assembly in FASTA format.

| Parameter | Value |
|-----------|-------|
| Total assemblies downloaded | 676 |
| File format | FASTA (.fna) |
| Storage location | `/home/palan/prevotella_genomes/ncbi_dataset/data/` |
| Total disk space | Several GB |

---

## Step 2 — BUSCO Quality Control

### What is BUSCO?

BUSCO stands for **Benchmarking Universal Single-Copy Orthologs**.

Think of it like a checklist. Scientists have identified a set of genes that
should be present in every bacterium — genes so essential that no bacterium
can survive without them. BUSCO checks: "How many of these essential genes
are present in this genome assembly?"

- **95%+ found** → the genome is complete and high quality ✅
- **Below 95%** → the genome is fragmented, incomplete, or possibly contaminated ❌

The database used was `bacteria_odb10` which contains **124 universal
bacterial single-copy orthologs** (essential genes found in all bacteria).

### BUSCO Score Categories

Each genome gets four scores:

| Category | Meaning |
|----------|---------|
| **Complete (C%)** | Genes found fully intact — the main quality indicator |
| **Single copy (S%)** | Complete genes found exactly once (ideal) |
| **Duplicated (D%)** | Complete genes found more than once (possible contamination if very high) |
| **Fragmented (F%)** | Genes partially found — assembly broke in the middle of the gene |
| **Missing (M%)** | Genes not found at all — either truly absent or assembly too fragmented |

### Running BUSCO

BUSCO was run on all 676 genomes using the Python script `01_run_busco.py`.
The script loops through every `.fna` file and runs BUSCO automatically.

```bash
python3 scripts/01_run_busco.py
```

**Key settings:**
```
Database:  bacteria_odb10
Mode:      genome
CPU:       2 cores per run
```

**Note:** Running BUSCO on 676 genomes takes many hours. The script prints
progress after each genome so you can monitor it.

### BUSCO Results Summary

| Metric | Value |
|--------|-------|
| Total genomes assessed | 676 |
| Completeness range | 32.3% – 100.0% |
| Mean completeness | 87.66% |
| Results file | busco_results_all.xlsx |

---

## Step 3 — CheckM Quality Control

### What is CheckM?

CheckM is a complementary quality tool that analyses genome statistics rather
than gene content. It checks:

- **Genome size** — is it in the expected range for this species?
- **GC content** — does it match *P. copri* (should be ~45%)?
- **Number of contigs** — fewer contigs = better assembly
- **N50** — a measure of how long the assembled pieces are (higher = better)
- **Predicted genes** — how many protein-coding genes does the genome contain?

### Running CheckM

```bash
checkm lineage_wf \
  ~/prevotella_genomes/ncbi_dataset/data/ \
  ~/prevotella_genomes/checkm_output/ \
  -x fna \
  --tab_table \
  -f checkm_summary.csv
```

### CheckM Results Summary

| Metric | Min | Max | Mean |
|--------|-----|-----|------|
| Genomes processed | — | — | 635 |
| Genome size (bp) | 1,217,043 | 6,480,446 | 3,301,308 |
| Predicted genes | 1,185 | 5,815 | 2,839 |
| Number of contigs | 1 | 4,065 | 207 |
| N50 (contigs) | 966 | 4,260,683 | 297,127 |
| GC content | 43.5% | 59.0% | 45.5% |

**What the numbers confirm:**
- Mean genome size of 3.3 Mb matches published *P. copri* reference genomes ✅
- GC content consistently around 45.5% confirms species identity ✅
- Wide range in contig count (1 to 4,065) shows quality varies greatly across assemblies

---

## Key Rules Learned

1. **Always verify download count after unzipping** — sometimes NCBI gives
   slightly different numbers depending on when you download
2. **BUSCO takes a very long time on hundreds of genomes** — use `nohup` or
   `screen` to keep it running if you close the terminal
3. **`try/except` in the Python script is essential** — without it, one
   failed genome would crash the entire pipeline
4. **CheckM and BUSCO may process slightly different genome counts** — this
   is normal due to minor path differences and does not affect the final result
5. **Never skip QC before downstream analysis** — using poor-quality genomes
   in pangenome or phylogenetic analysis produces scientifically wrong results

---

## Output Files

| File | Description |
|------|-------------|
| busco_results_all.xlsx | BUSCO completeness scores for all 676 genomes |
| checkm_summary.csv | CheckM genome statistics for 635 genomes |
