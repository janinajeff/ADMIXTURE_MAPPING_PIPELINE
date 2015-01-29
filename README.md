# Admixture Mapping from start to finish

This pipeline wil provide a detailed workflow for performing admixture mapping using local ancestry estimates from genome-wide genotype data. 

This pipeline will achieve the following:

####  1. Phasing using SHAPEIT
####  2. Convert SHAPEIT output into RFMIX input
####  3. Perform local ancestry inference using RFMIX
####  4. Convert RFMIX output into HAPMIX format for MIXSCORE
####  5. Perform two-way mapping using the Pasanuic et al paper
####  6. Plotting genome wide results


# Phasing
 This an extension to Alicia Martin's ancestry pipeline that includes two-way and three-way admixture mapping. 
Found here https://github.com/armartin/ancestry_pipeline . Phasing was performed using SHAPEIT and 1000 genomes phase 3 reference samples (AFR, EUR, AMR).

Using QC'd genotype files and the reference data, check and confirm the overlapping SNPs between the two datasets using -check function in ShapeIT.

``` 
for i in {1..22};
do echo /sc/orga/projects/ipm/janina/bin/shapeit \
-check \
--input-ref /sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3_chr${i}.hap.gz \
/sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3_chr${i}.legend.gz \
/sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3.sample \
--input-bed /sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.bed \
/sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.bim \
/sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.fam \
--input-map /sc/orga/projects/ipm/janina/DATA/1KG/genetic_map_chr${i}_combined_b37.txt \
--output-log /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/ALL_check_fwd_cleaned_hg19_ref_chr${i}.mendel > SHAPEITCHECK.chr${i}.sh;
done


for i in {1..22};
do echo sh SHAPEITCHECK.chr${i}.sh > SHAPEIT_CHECK_${i}.pbs;
done

for i in {1..22};
do bsub -P acc_ipm2 -q alloc  -W 24:00 -e SHAPEIT_CHECK_${i}.err -o SHAPEIT_CHECK_${i}.out < SHAPEIT_CHECK_${i}.pbs;
done
```

