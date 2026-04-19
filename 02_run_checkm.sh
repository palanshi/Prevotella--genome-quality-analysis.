# Session 2 — Genome Filtering (Keeping ≥ 95% Complete Genomes)

**Species:** *Prevotella copri*
**Date:** April 2026
**Environment:** Ubuntu 22.04 | Python 3.x

---

## Objective

From the 676 genomes assessed by BUSCO, identify and keep only the
high-quality assemblies with BUSCO completeness ≥ 95%. These 442 confirmed
high-quality genomes form the clean dataset for any future analysis.

---

## Why 95% Completeness as the Threshold?

The 95% cutoff is the **international standard** used in published microbial
genomics papers. Here is the reasoning:

- A genome with 95%+ BUSCO completeness has **at least 118 out of 124**
  universal bacterial genes present and intact
- This means the assembly captured essentially the entire genome during
  sequencing — it is not heavily fragmented
- Genomes below 95% are either from low-coverage sequencing runs, highly
  contaminated samples, or poor assembly algorithms
- Using such genomes in downstream analyses (pangenome, phylogenetics)
  introduces noise and unreliable results

The 95% threshold is used by:
- The Joint Genome Institute (JGI) genome quality standards
- NCBI genome submission guidelines
- Hundreds of published microbiome and comparative genomics papers

---

## The Filtering Script

A Python script reads the BUSCO results file and separates genomes into
two groups: passing (≥ 95%) and failing (< 95%).

```python
# Core filtering logic
THRESHOLD = 95.0

for row in busco_results:
    completeness = float(row["Complete"])
    if completeness >= THRESHOLD:
        passing.append(row)
    else:
        failing.append(row)
```

Run it with:
```bash
python3 scripts/02_filter_genomes.py
```

---

## Filtering Results

| Category | Count | Percentage |
|----------|-------|-----------|
| Total genomes assessed by BUSCO | 676 | 100% |
| **HIGH-QUALITY (completeness ≥ 95%)** | **442** | **65.4%** |
| Low-quality (completeness < 95%) | 234 | 34.6% |

### Stats of the 442 High-Quality Genomes

| Metric | Value |
|--------|-------|
| Minimum completeness | 95.0% |
| Maximum completeness | 100.0% |
| Mean completeness | 98.71% |
| These represent | Trusted *P. copri* genomes ready for analysis |

---

## What Happened to the 234 Rejected Genomes?

The 234 genomes below 95% completeness were rejected for the following reasons:

| Reason | Plain English |
|--------|--------------|
| Low sequencing coverage | The DNA was not sequenced deeply enough — like reading a book but skipping many pages |
| Highly fragmented assembly | The genome was broken into thousands of tiny pieces that could not be joined properly |
| Possible contamination | The sample may have contained DNA from other organisms mixed in |
| Poor assembly algorithm | Older or less accurate software produced an incomplete reconstruction |

These genomes are saved separately in `low_quality_genomes.csv` for reference
but are excluded from all downstream analysis.

---

## Scientific Significance of the 442 Genomes

Having **442 high-quality *Prevotella copri* genomes** is a substantial
dataset. To put this in context:

- Most published *P. copri* genomic studies used fewer than 100 genomes
- 442 genomes allows statistically robust pangenome analysis
- This dataset spans diverse geographic origins and host populations,
  captured in the metadata from NCBI
- The mean completeness of 98.71% is exceptionally high — these are
  near-perfect genome assemblies

---

## Output Files

| File | Description |
|------|-------------|
| high_quality_genomes.csv | 442 genomes passing ≥ 95% BUSCO completeness |
| low_quality_genomes.csv | 234 genomes below threshold (kept for reference) |

---

## Suggested Next Steps

With 442 confirmed high-quality *P. copri* genomes, the natural next
steps for this project are:

**1. Gene Annotation with Prokka**
```bash
prokka --outdir annotation/GCA_XXXXXX --prefix GCA_XXXXXX genome.fna
```
Prokka identifies and names every gene in each genome — turning raw DNA
sequence into a list of named genes with functions.

**2. Pangenome Analysis with Roary or Panaroo**
```bash
roary -e -n -v annotation/*/*.gff
```
A pangenome analysis finds which genes are shared by ALL 442 strains
(core genome) vs genes present in only some strains (accessory genome).
This reveals the genomic diversity of *P. copri* as a species.

**3. Phylogenetic Tree**
Build an evolutionary tree showing how the 442 strains are related to
each other — which strains are closely related and which are distantly related.

**4. Virulence and Resistance Gene Screening**
Screen all 442 genomes for known virulence factors and antibiotic
resistance genes using tools like AMRFinder or VFDB.
