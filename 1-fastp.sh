
#!/bin/bash
#env:RNAseq
names=`ls`
for name in ${names[@]};
do
/together_sdb/zhoujiaqi/software/fastp-master/fastp --thread 3 -i ./${name}/${name}_1.fq.gz -o ./${name}/clean${name}_1.fq.gz  -I ./${name}/${name}_2.fq.gz -O ./${name}/clean${name}_2.fq.gz -j ./${name}/${name}.json -h ./${name}/${name}.html 
done

