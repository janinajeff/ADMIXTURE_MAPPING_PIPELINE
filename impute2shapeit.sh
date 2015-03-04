#################################################
# January 3, 2015                           	#
# Janina M Jeff                            	#
# This script converts downloaded phased 1kG 	#
# Genome reference sample and phased haplotype	#
# files from reference format to regular phased #
# output.					#
#################################################
#!/bin/bash

if [ $# -lt 4 ]; then
  echo "Usage: $0 samplefile.sample reflegendfile.legend referencehaplotypes.haps outputfilename"
  exit 1
fi

SAMPLE="$1"
LEGEND="$2"
HAPS="$3"
OUT="$4"

echo "making sample file"
sed 's:female:2:g' <"$SAMPLE" | sed 's:male:1:g' |sed "s:$: 0:" |sed "s:$: 0:" |sed "s:$: 0:" | sed "s:$: -9:"| \
awk '{print $1 " " $1 " " $5" " $6" " $7 " " $4 " " $8 " " }' > "$OUT".sample

echo "merging legend file with haplotypes"

sed 's/:/ /g' <"$LEGEND" | sed "s:$: 21:"| awk '{print $15 " " $1 " " $2 " " $3" " $4}' > "$OUT".legend.int
sed '2, $!d' "$OUT".legend.int -i
paste -d " " "$OUT".legend.int "$HAPS" > "$OUT".haps

rm "$OUT".legend.int

echo "Done!"

exit 0
