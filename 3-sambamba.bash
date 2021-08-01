

#!/bin/bash

##env:ATACseq
names=`ls`
for name in ${names[@]};
do
cd ./${name}
cd GATK
sambamba markdup --overflow-list-size 600000  --tmpdir='./'  -r  $name.bam  ${name}_rmd.bam
cd '/media/zhoujiaqi/TOSHIBA EXT/Data/circRNA_ICC_0910/rawdata'
done
