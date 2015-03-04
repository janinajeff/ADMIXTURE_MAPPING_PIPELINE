for i in {1..22}; \
do sed 's/\(.\) \(.\)/\1\2/g' T2D_AA_RFMIX_Chr${i} > Chr${i}.int; done \

for i in {1..22}; \
do sed 's/11/2/g' < Chr${i}.int | sed 's/22/2/g' | sed 's/33/0/g' | sed 's/12/2/g' \
| sed 's/13/1/g' | sed 's/23/1/g' | sed s'/21/2/g' | sed 's/31/1/g' | sed 's/32/1/g' > T2D_AA_Chr${i}.MIXSCORE; done

for i in {1..22}; do rm Chr${i}.int ; done

for i in {1..22}; do sed s': ::g' T2D_AA_Chr${i}.MIXSCORE -i; done
