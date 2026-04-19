# Prevotella copri Genome Quality Control Pipeline
### 676 Genome Assemblies | BUSCO + CheckM | NCBI Dataset

[![Species](https://img.shields.io/badge/Species-Prevotella%20copri-4CAF50)](https://www.ncbi.nlm.nih.gov/)
[![Genomes](https://img.shields.io/badge/Genomes-676%20assemblies-blue)](https://www.ncbi.nlm.nih.gov/)
[![QC](https://img.shields.io/badge/QC-BUSCO%20%2B%20CheckM-orange)](https://busco.ezlab.org/)
[![Python](https://img.shields.io/badge/Python-3.x-yellow)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Project Overview

This project performs **genome quality control (QC)** on 676 publicly available
*Prevotella copri* genome assemblies downloaded from NCBI. The goal is to identify
high-quality, complete genomes that are suitable for downstream genomic analyses
such as pangenome construction, phylogenetics, or comparative genomics.

The core biological question is:

> **Out of 676 downloaded *Prevotella copri* genomes, how many are complete,
> high-quality assemblies that can be trusted for scientific analysis?**

This matters because publicly available genome assemblies vary enormously in quality.
Some are nearly perfect, others are highly fragmented or contaminated. Using poor
quality genomes in downstream analysis produces unreliable scientific conclusions.

---

## Background — Key Terms Explained

| Term | Plain English Explanation |
|------|--------------------------|
| ***Prevotella copri*** | A gut bacterium found in the human intestinal microbiome. Associated with inflammation, rheumatoid arthritis, and diet. One of the most studied gut bacteria in microbiome research. |
| **Genome Assembly** | The reconstructed DNA sequence of an organism, pieced together from millions of short DNA reads. Think of it like reassembling a shredded document. |
| **BUSCO** | Benchmarking Universal Single-Copy Orthologs. A tool that checks genome completeness by looking for genes that should be present in every bacterium. If most are present → good genome. |
| **CheckM** | A tool that evaluates genome quality by checking genome size, GC content, number of contigs, and predicted gene count. |
| **Completeness** | What percentage of the expected genes are actually found in the genome assembly. 95%+ is considered high quality. |
| **Contig** | A continuous piece of assembled DNA. A perfect genome has 1 contig (chromosome). Fragmented assemblies have thousands of small contigs. |
| **N50** | A measure of assembly quality. If you sort all contigs by length and add them up until you reach 50% of the total genome length, the length of that contig is the N50. Higher N50 = better assembly. |
| **GC Content** | The percentage of DNA bases that are G or C (vs A or T). Consistent GC% across genomes of the same species confirms they are truly the same species. |
| **FASTA format** | The standard text file format for storing DNA sequences. Each entry starts with `>genome_name` followed by the DNA sequence. |

---

## Repository Structure

```
prevotella-copri-qc/
│
├── README.md                        ← You are here
├── LICENSE
│
├── scripts/
│   ├── 01_run_busco.py              ← Runs BUSCO on all 676 genome files
│   └── 02_filter_genomes.py        ← Filters genomes with completeness ≥ 95%
│
├── results/
│   ├── busco_results_all.xlsx       ← BUSCO scores for all 676 genomes
│   ├── checkm_summary.csv           ← CheckM stats for all 635 genomes
│   └── high_quality_genomes.csv    ← Final list of 442 passing genomes
│
└── session_notes/
    ├── session_01_download_qc.md    ← How data was downloaded and QC run
    └── session_02_filtering.md      ← How genomes were filtered
```

---

## Data Source

| Parameter | Value |
|-----------|-------|
| **Species** | *Prevotella copri* |
| **Source Database** | NCBI (National Center for Biotechnology Information) |
| **Data Type** | Genome assemblies (FASTA format — `.fna` files) |
| **Total Downloaded** | 676 genome assemblies |
| **Download Location** | `/home/palan/prevotella_genomes/ncbi_dataset/data/` |

---

## Analysis Pipeline

```
NCBI Database
     │
     ▼
Download 676 Prevotella copri genome assemblies (.fna files)
     │
     ├──────────────────────────────────┐
     ▼                                  ▼
BUSCO Quality Control               CheckM Quality Control
(bacteria_odb10 database)           (genome statistics)
676 genomes scored                  635 genomes processed
     │                                  │
     ▼                                  ▼
Completeness score per genome       Genome size, GC%, N50,
(0% to 100%)                        predicted genes per genome
     │
     ▼
Python filtering script
Keep genomes with completeness ≥ 95%
     │
     ▼
442 HIGH-QUALITY GENOMES CONFIRMED
234 low-quality genomes removed
```

---

## Key Results

### BUSCO Quality Assessment

| Metric | Value |
|--------|-------|
| Tool | BUSCO v5 |
| Database | bacteria_odb10 (124 conserved bacterial genes) |
| Total genomes assessed | 676 |
| Completeness range | 32.3% – 100.0% |
| Mean completeness (all genomes) | 87.66% |
| **Genomes passing ≥ 95% completeness** | **442** |
| Mean completeness of passing genomes | 98.71% |
| Genomes rejected (< 95%) | 234 |

### CheckM Genome Statistics

| Metric | Min | Max | Mean |
|--------|-----|-----|------|
| Total genomes processed | — | — | 635 |
| Genome size (bp) | 1,217,043 | 6,480,446 | 3,301,308 |
| Predicted genes | 1,185 | 5,815 | 2,839 |
| Number of contigs | 1 | 4,065 | 207 |
| N50 (contigs) | 966 | 4,260,683 | 297,127 |
| GC content | 43.5% | 59.0% | 45.5% |

### What the Numbers Mean

**Genome size ~3.3 Mb** is consistent with published *Prevotella copri* reference
genomes, confirming the downloads are genuine *P. copri* assemblies.

**GC content ~45.5%** is highly consistent across all 635 genomes, confirming
species-level identity — contamination or wrong-species downloads would show
very different GC%.

**442 out of 676 (65.4%)** genomes passed the quality threshold. The 234 rejected
genomes were likely low-coverage sequencing runs or highly fragmented assemblies
not suitable for genomic analysis.

---

## How to Reproduce This Analysis

### Prerequisites

**System:** Linux (Ubuntu 22.04 recommended)
**Software required:**
- Python 3.x
- BUSCO v5 (`conda install -c conda-forge -c bioconda busco`)
- CheckM (`pip install checkm-genome`)

### Step 1 — Download genomes from NCBI

```bash
# Create project directory
mkdir -p ~/prevotella_genomes
cd ~/prevotella_genomes

# Download all Prevotella copri assemblies using NCBI datasets tool
datasets download genome taxon "Prevotella copri" \
  --assembly-source all \
  --filename prevotella_copri_genomes.zip

unzip prevotella_copri_genomes.zip
```

### Step 2 — Run BUSCO on all genomes

```bash
# Make sure you are in your project directory
cd ~/prevotella_genomes

# Run the BUSCO pipeline script
python3 scripts/01_run_busco.py
```

This will run BUSCO on every `.fna` file found inside the genome folder.
Each genome takes 2–5 minutes. With 676 genomes this will take several hours.
Results are saved per genome and also compiled into `busco_results_all.xlsx`.

### Step 3 — Run CheckM

```bash
# Point CheckM at your genome folder
checkm lineage_wf \
  ~/prevotella_genomes/ncbi_dataset/data/ \
  ~/prevotella_genomes/checkm_output/ \
  -x fna \
  --tab_table \
  -f checkm_summary.csv
```

### Step 4 — Filter high-quality genomes

```bash
python3 scripts/02_filter_genomes.py
```

This reads the BUSCO results and outputs the list of genomes with
completeness ≥ 95% to `results/high_quality_genomes.csv`.

---

## Lessons Learned

| Problem | Cause | Fix |
|---------|-------|-----|
| BUSCO failed on some genomes | Corrupted or empty FASTA files in download | Added try/except in Python script to skip failed genomes and continue |
| Some genomes had very low completeness (32%) | Poor sequencing coverage or highly fragmented assembly | Removed by ≥ 95% completeness filter |
| CheckM processed fewer genomes (635) than BUSCO (676) | Some genome files not found by CheckM path | Minor path issue — does not affect final filtered set |
| BUSCO takes very long to run | Each genome takes 2-5 minutes × 676 genomes | Used `--cpu 2` per run and ran sequentially with progress tracking |

---
---

## Citation

If you use this pipeline or dataset, please cite:

> Parks DH, et al. CheckM: assessing the quality of microbial genomes
> recovered from isolates, single cells, and metagenomes.
> *Genome Research*, 2015.

> Simão FA, et al. BUSCO: assessing genome assembly and annotation
> completeness with single-copy orthologs. *Bioinformatics*, 2015.

> *Prevotella copri* genome assemblies from NCBI Assembly database.
> https://www.ncbi.nlm.nih.gov/assembly

---

## Author

Anshika Pal
BSc Biochemistry | Institute of Home Economics

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
