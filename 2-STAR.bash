

#!/bin/bash

#env:STAR2
names=`ls`
for name in ${names[@]};
do
cd ./${name}
mkdir GATK
cd GATK
STAR \
--readFilesIn ../clean${name}_1.fq.gz ../clean${name}_2.fq.gz  \
--genomeDir /together_sdb/zhoujiaqi/index/GRCh38_gencode_v22_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa.star.idx  \
--runThreadN 10 \
--twopassMode Basic \
--outReadsUnmapped None \
--chimSegmentMin 12  \
--alignIntronMax 100000 \
--chimSegmentReadGapMax parameter 3  \
--alignSJstitchMismatchNmax 5 -1 5 5  \
--readFilesCommand zcat \
--outFileNamePrefix  ${name}_ 

rm ../clean${name}_1.fq.gz 
rm ../clean${name}_2.fq.gz  
mv ${name}_Aligned.out.sam $name.sam
samtools sort -o $name.bam  $name.sam
samtools index $name.bam
samtools flagstat $name.bam  > $name.flagstat

cd '/media/zhoujiaqi/TOSHIBA EXT/Data/circRNA_ICC_raw'
done
