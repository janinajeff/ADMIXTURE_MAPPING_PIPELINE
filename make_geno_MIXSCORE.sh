echo "transposing plink raw files files"
for i in {1..22}; do \
awk '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
	print str
    }
}' Chr${i}.AA.T2D.raw > Chr${i}_trans; done
echo "removing first 6 rows in plink file"
for i in {1..22}; do sed '7,$!d' Chr${i}_trans > Chr${i}_snps; done 
echo "remove 1st column with SNP names"
for i in {1..22}; do cat Chr${i}_snps | awk '{$1=""; print substr($0,2)}' Chr${i}_snps > Chr${i}_snponly; done
echo "Set missing NAs to 9 and remove spaces for MIXSCORE, see test_snpsonly_noNA and test_mixscore"
for i in {1..22}; do sed 's/NA/9/g' Chr${i}_snponly | sed 's/ //g' > Chr${i}_mixscore_geno; done
rm Chr*_trans
rm Chr*_snps
rm Chr*_snponly
echo "done!"
