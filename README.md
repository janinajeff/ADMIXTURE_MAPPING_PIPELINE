# ADMIXTURE_MAPPING_PIPELINE_African_Americans

This pipeline wil provide a detailed workflow for performing admixture mapping using local ancestry estimates from genome-wide genotype data. 

This pipeline will achieve the following:

1. Phasing using SHAPEIT
2. Convert SHAPEIT output into RFMIX input
3. Perform local ancestry inference using RFMIX
4. Convert RFMIX output into HAPMIX format for MIXSCORE
5. Perform two-way mapping using the Pasanuic et al paper
6. Plotting genome wide results


# Phasing
 This an extension to Alicia Martin's ancestry pipeline that includes two-way and three-way admixture mapping. 
Found here https://github.com/armartin/ancestry_pipeline . Phasing was performed using SHAPEIT and 1000 genomes phase 3 reference samples (AFR, EUR, AMR).
