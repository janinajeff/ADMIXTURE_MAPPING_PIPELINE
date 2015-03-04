# Admixture Mapping from start to finish

This pipeline wil provide a detailed workflow for performing admixture mapping using local ancestry estimates from genome-wide genotype data. 

This pipeline will achieve the following:

####  1. Phasing using SHAPEIT
####  2. Make RFMIX input files
####  3. Perform local ancestry inference using RFMIX
####  4. Convert RFMIX output into HAPMIX format for MIXSCORE
####  5. Perform admixture mapping using the Pasanuic et al
#####      5A. African Americans
######        5A1. MIXSCORE
######        5A2. Using mixomatic in R (coming soon!)
#####      5B. Hispanic/Latinos Using mixomatic in R (coming soon!)
####  6. Plotting genome wide results in R


## Phasing Using SHAPEIT
 This an extension to Alicia Martin's ancestry pipeline that includes two-way and three-way admixture mapping. 
Found here https://github.com/armartin/ancestry_pipeline . Phasing was performed using SHAPEIT and 1000 genomes phase 3 reference samples (AFR, EUR, AMR).


### Pre Phasing QC
Using QC'd genotype files and the reference data, check and confirm the overlapping SNPs between the two datasets using -check function in ShapeIT.

See usage below
``` 
/sc/orga/projects/ipm/janina/bin/shapeit \
-check \
--input-ref /sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3_chr${i}.hap.gz \
/sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3_chr${i}.legend.gz \
/sc/orga/projects/ipm/janina/DATA/1KG/1000GP_Phase3.sample \
--input-bed /sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.bed \
/sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.bim \
/sc/orga/projects/ipm/janina/DATA/ILLUMINA/ipm-combo-norelateds.${i}.nodups.fam \
--input-map /sc/orga/projects/ipm/janina/DATA/1KG/genetic_map_chr${i}_combined_b37.txt \
--output-log /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/ALL_check_fwd_cleaned_hg19_ref_chr${i}.mendel 
```

### Phasing
After QC all samples were phased at using AFR, EUR, and AMR reference samples currently available from 1000G Phase 3.

See usuage below
```
/sc/orga/projects/ipm/janina/bin/shapeit \
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
```

## Making RFMix Input Files
RFMix files can be made from SHAPEIT or BEAGLE formatted files. Similiar to Alicia Martin's pipeline, I used SHAPEIT for phasing but I have included a script to convert BEAGLE formatted files (from PLINK bed files) for RFMIX and can provide more detail upon request.

### SHAPEIT to RFMIX
I made small modifications Alcia Martin's code shapeit2rfmix.py script (shapeit2rfmix_JMJ.py) for my data. My reference sample data was originally formatted in IMPUTE2 format, so wrote a short shell (impute2shapeit.sh) script to convert these files before using the shapeit2rfmix script. 

See example below for usage

```
sh impute2shapeit.sh 1000GP_Phase3.sample 1000GP_Phase3_chr11.legend 1000GP_Phase3_chr11.hap shapeitrefconvert_11
```

See usuage below for shapeit2rfmix_JMJ.py

```
python /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/LOCANC/shapeit2rfmix_JMJ.py \
--shapeit_hap1 /sc/orga/projects/ipm/janina/DATA/1KG/shapeitrefconvert_${i}.haps \
--shapeit_hap_admixed /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/SHAPEIT/ALL_fwd_cleaned_hg19_ref_chr${i}.haps \
--shapeit_sample1 /sc/orga/projects/ipm/janina/DATA/1KG/shapeitrefconvert_22.sample \
--shapeit_sample_admixed /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/SHAPEIT/ALL_fwd_cleaned_hg19_ref_chr${i}.sample \
--ref_keep /sc/orga/projects/ipm/janina/DATA/1KG/AFR_EUR_AMR.txt \
--admixed_keep /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/PHASING/IDs.txt \
--chr ${i} \
--genetic_map /sc/orga/projects/ipm/janina/DATA/1KG/genetic_map_chr \
--out /sc/orga/projects/ipm/janina/ADMIXTURE_PIPELINE/LOCANC/RFMIX_INPUT.${i} 

```


### Beagle to RFMix (Optional)
Files in Beagle format (usually converted from plink files using FC gene) can be converted into the RFMIX alleles file using the python scipt 'RFMIX_BEAGLE_Parser.py'. This script is supposed to check for strand flips, skip palindromic site, and recode alleles as 0 and 1 for RFMix allele matrix.

### Making class files

The shapeit2rfmix script assumes Phasing was done separately per population, so the classes file needed to be adjusted accordingly. This is just a one file that denotes which individuals are references and which are samples for RFMIX. This can be done easily using a print or echo and the same class files can be used for all chromosomes since the order of the samples are the same up to this point.

### Genetic Map file

The genetic map file per chromosome can be downloaded from the 1000G website ("genetic_map_chr*_combined_b37.txt"). This file can be directly uploaded into RFMix files if the sites of interest have been extracted. Keep in mind a modified version of this files is made when using the shapeit2rfmix_JMJ.py script, *.map (output files name from script).


## Running RFMix

RFMix can be downloaded here https://sites.google.com/site/rfmixlocalancestryinference/. Here is an example on how to run RFMix but there is nice documentation now included in the package.

```
/sc/orga/projects/ipm/janina/bin/RFMix_PopPhased -m RFMIX_INPUT.22_chr22.snp_locations -p ALL.classes -a RFMIX_INPUT.22_chr22.alleles  -r 0 -o chr22_test
```
# Admixture Mapping in African Americans
The next few steps are how to perform admixture mapping using MIXSCORE, which is currently limited to African Americans.

## Making MIXSCORE input files.

MIXSCORE runs several statistics that extend beyond both GWAS and admixture mapping independently to create a summary statistic that takes into account multiple hypothesis to identify putative genetic associations. Information about MIXSCORE can be found here and downloaded here. MIXSCORE requires genome-wide genotype information, global ancestry estimates (per individual), local ancestry calls (per SNP for every individual), phenotype information, covariate information (if necessary), and a parameter file.See sample files, mixscore.GENO, mixscore.GLOBANC, mixscore.LOCANC, mixscore.PHENO, mixscore.par

### Converting RFMix Local ancestry calls to HapMix format for MIXSCORE
I used a script that converts three way local ancestry calls from RFMix and collapses and recodes them into HapMix format for MIXSCORE, convert_RFMIX_MIXSCORE.sh, this will work for African Americans and codes RFMix output in to African vs Non African diplotype calls. See mixscore.LOCANC for an example

``` sh convert_RFMIX_MIXSCORE.sh ```

### Creating Global Ancestry Calls
Global ancestry can be calculated using the local ancestry calls or using the ADMIXTURE Program (I can include details upon reuqest on how to run this). I used the later which is fairly simple to use. You want to extract the proportion of European Ancestry for MIXSCORE in African Americans, so just one column, % Euro global ancestry, for each person indicated by row. Make sure the global ancestry calls are in the same order as the local ancestry call!See mixscore.GLOBANC for an example

### Converting Genotype Files
MIXSCORE also requires a genotype file if you are calculating the ATT, SNP1,SUM, or MIX statistic. Please not this is not need for just running case-only admixture. Using Plink.raw files where genotypes are coded 0,1,2 copies of the minor allele, I converted this into Eigenstrat format using a shell script, make_geno_MIXSCORE.sh See mixscore.GENO for an example

### Phenotype Files 
MIXSCORE uses a phenotype file that is one line and codes cases as 1 and controls as 0 for each individual in the same order as the other files. This file has no spaces, mixscore.PHENO

### Parameter Files

MIXSCORE requires a simple parameter file that states how many SNPs are being tested, how many samples to expect, the location of the input files, and the name and location of the output file. You can add additional options in this file too, such as running quantitative traits, see manual. Unfortunately mixscore does not allow a covariates (a major limitation to the method).
Here is an example of a parameter file for one chromosome for the ADM (case-only admixture mapping) statistic. 

```
nsamples:3342
nsnps:8229
phenofile: mixscore.PHENO
ancfile: mixscore.LOCANC
genofile: mixscore.GENO
thetafile: mixscore.GLOBANC
outfile: AA_ADM_STAT
```

## Running MIXSCORE
Each statistic the MIXSCORE package has needs to be run separately. The SNP1 and ADM statistics run pretty quick (< 30 min for all chromosomes), whereas as the SUM and MIX statisics take hours. Here is an example fo running MIXSCORE ADM statistic.

```
for i in {1..22}; do mixscore ADM T2D_AA_Chr${i}.ADM.par ; done
```
## Running mixomatic
Alternatively, if you just want to run admixture mapping with both cases and controls and/or the SUM of the association and admixture association you can use mixomatic. Mixomatic is a R script (in process by Chris Gignoux at Stanford) and is nice in the sense that it incorporates cases and controls and allows the user to add covariates, including genotype information. This method uses likilhood ratio test to determine whether local ancetsry explains cases. This methods can also be used for quantitative traits.I can give more detail upon request.

## Plotting Results in R
MIXSCORE output files prints the Chi2 for each SNP by row. To make a manhattan plot separate chromosome output files need to be merged into one file. Once this is complete the p-value for the Chi2 need to be calculated for each SNP. Finally the original map information needs to merged into this file, including SNP name and BP location. The final file should have SNP, BP, and P-value columns and can be easily plotting using qqman.r source code found here http://www.gettinggeneticsdone.com/2014/05/qqman-r-package-for-qq-and-manhattan-plots-for-gwas-results.html



