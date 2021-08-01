

#!/bin/bash
##env:HICPRO
names=`ls`
for name in ${names[@]};
do
cd ./${name}
cd GATK
gatk='/home/zhoujiaqi/gatk-4.1.4.0/gatk'
GENOME='/together_sdb/zhoujiaqi/index/GRCh38_gencode_v22_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa'
#$gatk  CreateSequenceDictionary -R $GENOME # 最新版gatk，这个步骤非常快
$gatk SplitNCigarReads -R $GENOME \
-I ${name}_rmd.bam \
-O  ${name}_rmd_split.bam

DBSNP=/together_sdb/zhoujiaqi/index/bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf
kgSNP=/together_sdb/zhoujiaqi/index/bundle/resources_broad_hg38_v0_1000G_phase1.snps.high_confidence.hg38.vcf
kgINDEL=/together_sdb/zhoujiaqi/index/bundle/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf


#$gatk IndexFeatureFile -F /together_sdb/zhoujiaqi/index/bundle/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf
# 因为我的star比对得到的bam文件里面没有 Read groups
# 参考：https://gatkforums.broadinstitute.org/gatk/discussion/6472/read-groups
$gatk AddOrReplaceReadGroups   -I  ${name}_rmd_split.bam  \
  -O  ${name}_rmd_split_add.bam -LB $name -PL ILLUMINA -PU $name -SM $name
$gatk  BaseRecalibrator \
        -I  ${name}_rmd_split_add.bam \
        -R $GENOME \
        -O ${name}_recal.table --known-sites $kgSNP --known-sites $kgINDEL
$gatk  ApplyBQSR \
        -I  ${name}_rmd_split_add.bam -R $GENOME --output ${name}_recal.bam -bqsr ${name}_recal.table

bed=/together_sdb/zhoujiaqi/index/bundle/exon_probe.GRCh38.gene.150bp.bed

$gatk HaplotypeCaller -R $GENOME -I ${name}_recal.bam -O ${name}_gatk.gvcf -dont-use-soft-clipped-bases \
--standard-min-confidence-threshold-for-calling 20 \
--dbsnp $DBSNP

$gatk VariantFiltration -R $GENOME -V ${name}_gatk.gvcf -O ${name}_filtered_gatk.gvcf --window 35 --cluster 3 --filter-name "FS" --filter "FS>60.0" --filter-name "QD"  --filter "QD<2.0" --filter-name "SOR" --filter "SOR>3.0"

$gatk SelectVariants --select-type-to-include SNP -R $GENOME -V ${name}_filtered_gatk.gvcf  -O ${name}_filtered_gatk_SNP.vcf 

/together_sdb/zhoujiaqi/software/annovar/convert2annovar.pl --format vcf4 ${name}_filtered_gatk_SNP.vcf > ${name}_filtered_gatk_SNP.input

hgdb=/together_sdb/zhoujiaqi/index/annovarindex

/together_sdb/zhoujiaqi/software/annovar/table_annovar.pl  --buildver hg38 -protocol refGene,cytoBand --operation g,r  ${name}_filtered_gatk_SNP.input $hgdb 


#/together_sdb/zhoujiaqi/software/annovar/annotate_variation.pl -downdb -buildver hg38 -webfrom annovar refGene humandb
#/together_sdb/zhoujiaqi/software/annovar/annotate_variation.pl -downdb -buildver hg38 -downdb cytoBand humandb

cd '/media/zhoujiaqi/TOSHIBA EXT/Data/circRNA_ICC_0910/rawdata'
done