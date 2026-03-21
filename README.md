# Prevotella--genome-quality-analysis.
<br>
Genome Quality Assessment of Prevotella Strains
<br>
 Objective
<br>
To assess the quality of multiple Prevotella genomes by evaluating completeness and contamination using standard bioinformatics tools.
<br>
 Methodology
 <br>
A total of ~900 Prevotella genome assemblies were downloaded from the NCBI database using an Ubuntu-based environment.
Genome quality assessment was performed using BUSCO by executing command-line analysis on the downloaded genome dataset.
BUSCO output files were generated and converted into CSV format for further analysis.
A separate Python workspace was created within the project directory in Ubuntu. Using Python, a script was developed to:
Analyze BUSCO results
Filter genomes with completeness ≥ 95%
Quantify the number of high-quality genomes
Approximately 400 genomes were identified as complete based on BUSCO analysis.
To further validate genome quality, contamination assessment was performed using CheckM on the same dataset.
<br>
📊 Results
<br>
Total genomes analyzed: ~900
High-quality genomes (≥95% completeness): ~400
CSV file generated for structured analysis and interpretation
<br>
 Conclusion
<br>
The combined use of BUSCO and CheckM enabled reliable assessment of genome completeness and contamination. A substantial subset of Prevotella genomes met high-quality criteria and can be used for downstream genomic and comparative analyses.
