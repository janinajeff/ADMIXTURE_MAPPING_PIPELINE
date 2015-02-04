# Admixture Mapping from start to finish

This pipeline wil provide a detailed workflow for performing admixture mapping using local ancestry estimates from genome-wide genotype data. 

This pipeline will achieve the following:

####  1. Phasing using SHAPEIT
####  2. Make RFMIX input files
####  3. Perform local ancestry inference using RFMIX
####  4. Convert RFMIX output into HAPMIX format for MIXSCORE
####  5. Perform admixture mapping using the Pasanuic et al
#####      5A. African Americans
#####      5B. Hispanic/Latinos
####  6. Plotting genome wide results in R


## Phasing Using SHAPEIT
 This an extension to Alicia Martin's ancestry pipeline that includes two-way and three-way admixture mapping. 
Found here https://github.com/armartin/ancestry_pipeline . Phasing was performed using SHAPEIT and 1000 genomes phase 3 reference samples (AFR, EUR, AMR).


### Pre Phasing QC
Using QC'd genotype files and the reference data, check and confirm the overlapping SNPs between the two datasets using -check function in ShapeIT.

See usage below
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

### Phasing
After QC all samples were phased at using AFR, EUR, and AMR reference samples currently available from 1000G Phase 3.

See usuage below
```
for i in {1..22};
do echo /sc/orga/projects/ipm/janina/bin/shapeit \
--input-ref /sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3_chr${i}.hap \
/sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3_chr${i}.legend \
/sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3.sample \
--input-bed /sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.bed \
/sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.bim \
/sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.fam \
--input-map /sc/orga/projects/ipm/janina/DATA/1KG/genetic_map_chr${i}_combined_b37.txt \
--exclude-snp /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/ALL_check_fwd_cleaned_hg19_ref_chr${i}.mendel.snp.strand.exclude \
--include-grp /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/AFR_EUR_AMR.txt \
--output-max /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/ALL_fwd_cleaned_hg19_ref_chr${i}.haps /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/ALL_fwd_cleaned_hg19_ref_c$
done


for i in {1..22};
do echo sh PHASING.ALL.chr${i}.sh > PHASING.ALL.chr${i}.pbs;
done

for i in {1..22};
do bsub -P acc_ipm2 -q alloc  -W 72:00 -n 2 -R "rusage[mem=8000]" -R "span[ptile=4]" -J Phasing${i} -e PHASING.ALL.chr${i}.err -o PHASING.ALL.chr${i}.out < PHASING.ALL.chr${i}.pbs;
done

```
## Making RFMix Input Files
RFMix files can be made from SHAPEIT or BEAGLE formatted files. Similiar to Alicia Martin's pipeline, I used SHAPEIT for phasing but I have included a script to convert BEAGLE formatted files for RFMIX.

### SHAPEIT to RFMIX
I made small modifications Alcia Martin's code shapeit2rfmix.py script (shapeit2rfmix_JMJ.py) for my data. My reference sample data was originally formatted in IMPUTE2 format, so wrote a short shell (impute2shapeit.sh) script to convert these files before using the shapeit2rfmix script. 

See example below for usage

```
sh impute2shapeit.sh 1000GP_Phase3.sample 1000GP_Phase3_chr11.legend 1000GP_Phase3_chr11.hap shapeitrefconvert_11
```

See usuage below for shapeit2rfmix_JMJ.py

```
for i in {1..22};
do echo python /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/LOCANC/shapeit2rfmix_JMJ.py \
--shapeit_hap1 /sc/orga/projects/ipm/janina/DATA/1KG/shapeitrefconvert_${i}.haps \
--shapeit_hap_admixed /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/SHAPEIT/ALL_fwd_cleaned_hg19_ref_chr${i}.haps \
--shapeit_sample1 /sc/orga/projects/ipm/janina/DATA/1KG/shapeitrefconvert_22.sample \
--shapeit_sample_admixed /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/SHAPEIT/ALL_fwd_cleaned_hg19_ref_chr${i}.sample \
--ref_keep /sc/orga/projects/ipm/janina/DATA/1KG/AFR_EUR_AMR.txt \
--admixed_keep /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/IDs.txt \
--chr ${i} \
--genetic_map /sc/orga/projects/ipm/janina/DATA/1KG/genetic_map_chr \
--out /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/LOCANC/RFMIX_INPUT.${i} > SHAPEIT2RFMIX_${i}.sh; done


for i in {1..22};
do echo sh SHAPEIT2RFMIX_${i}.sh > SHAPEIT2RFMIX_${i}.pbs;
done

for i in {1..22};
do bsub -P acc_ipm2 -q alloc  -W 24:00 -e SHAPEIT2RFMIX_${i}.err -o SHAPEIT2RFMIX_${i}.out < SHAPEIT2RFMIX_${i}.pbs;
done

```


### Beagle to RFMix
Files in Beagle format (usually converted from plink files using FC gene) can be converted into the RFMIX alleles file using the python scipt 'RFMIX_BEAGLE_Parser.py'. This script is supposed to check for strand flips, skip palindromic site, and recode alleles as 0 and 1 for RFMix allele matrix.

Usuage
```
```


### Making class files

The shapeit2rfmix script assumes Phasing was done separately per population, so the classes file needed to be adjusted accordingly. I created a short shell script to this for my data, 'makeclassfile.sh'.

For usage see below...

### Genetic Map file

The genetic map file per chromosome can be downloaded from the 1000G website ("genetic_map_chr*_combined_b37.txt"). This file can be directly uploaded into RFMix files if the sites of interest have been extracted. Keep in mind a modified version of this files is made when using the shapeit2rfmix_JMJ.py script, *.map (output files name from script).
