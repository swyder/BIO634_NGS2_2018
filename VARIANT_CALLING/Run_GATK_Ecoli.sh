#!/bin/bash
set -o nounset
set -o errexit
set -x

 # BAM processing using PICARD, SNP calling using GATK

SAMTOOLS=/usr/bin/samtools   # version missing!
GATK=~/APPL/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar
PICARD=~/APPL/PICARD/picard.2.18.0.jar

 # IDEAS to improve the script:
 # add variable with memory parameter to java -Xmx6g
 # add 2> to capture errors
 # add input and output folders


REF_FILE=EcoliDH10B.fa
BAM_FILE=MiSeq_Ecoli_DH10B_110721_PF_subsample.bam
 # outfolder=gatk_variants

 # build indexes for Genome and BAM files
$SAMTOOLS faidx $REF_FILE
$SAMTOOLS index $BAM_FILE
java -jar $PICARD CreateSequenceDictionary R=$REF_FILE O=${REF_FILE%%.*}.dict

 # sort mappings by name to keep paired reads together
java -Xmx1g -jar $PICARD SortSam \
    I=$BAM_FILE \
    O=${BAM_FILE%%.*}_sorted.bam \
    SO=queryname \
    VALIDATION_STRINGENCY=LENIENT \
    2>SortSam_queryname.err

 # fix mate information and sort
java -Xmx1g -jar $PICARD FixMateInformation \
    I=${BAM_FILE%%.*}_sorted.bam \
    O=${BAM_FILE%%.*}_fixmate.bam \
    SO=coordinate \
    VALIDATION_STRINGENCY=LENIENT \
    2>FixMateInformation.err


 # mark duplicates
java -Xmx1g -jar $PICARD MarkDuplicates \
    I=${BAM_FILE%%.*}_fixmate.bam \
    O=${BAM_FILE%%.*}_rdup.bam \
    M=duplicate_metrics.txt \
    VALIDATION_STRINGENCY=LENIENT \
    #2>MarkDuplicates.err


 # Add Read Groups @RG
java -Xmx1g -jar $PICARD AddOrReplaceReadGroups \
    I=${BAM_FILE%%.*}_rdup.bam \
    O=${BAM_FILE%%.*}_rdup-rg.bam \
    RGID="NA18507" \
    RGLB="lib-NA18507" \
    RGPL="ILLUMINA" \
    RGPU="unkn-0.0" \
    RGSM="MiSeq_Ecoli_DH10B" \
    VALIDATION_STRINGENCY=LENIENT \
    # 2>AddOrReplaceReadGroups.err

 # Build BAM index for fast access
java -Xmx1g -jar $PICARD BuildBamIndex \
    I=${BAM_FILE%%.*}_rdup-rg.bam \
    2>BuildBamIndex.err


 # identify regions for indel local realignment of the selected chromosome
java -Xmx1g -jar $GATK -T RealignerTargetCreator \
    -R $REF_FILE \
    -I ${BAM_FILE%%.*}_rdup-rg.bam \
    -o target_intervals.list

 # perform indel local realignment of the selected chromosome
java -Xmx1g -jar $GATK -T IndelRealigner \
    -R $REF_FILE \
    -I ${BAM_FILE%%.*}_rdup-rg.bam \
    -targetIntervals target_intervals.list \
    -o ${BAM_FILE%%.bam}_realigned.bam

 # analyze patterns of covariation
 # only possible with known SNPs
 # for non-model organisms it is possiple to interpret the high quality fraction of called SNPs as knownSites 
 # and perform multiple rounds of BaseRecalibration and SNPcalling
 #java -Xmx1g -jar $GATK -T BaseRecalibrator -R $REF_FILE -I ${BAM_FILE%%.bam}_realigned.bam
 #  -knownSites ${dbsnp} -knownSites ${gold_indels} -o recal_data.table 2>BaseRecalibrator.err

 #1. Run UnifiedGenotyper
 # this takes approx. 1.8 min
java -Xmx1g -jar $GATK -T UnifiedGenotyper \
    -R $REF_FILE \
    -I ${BAM_FILE%%.bam}_realigned.bam \
    -ploidy 1 \
    -glm BOTH \
    -mbq 10 \
    -o raw_variants_UG.vcf

 #2. Run HaplotypeCaller
java -Xmx1g -jar $GATK -T HaplotypeCaller \
    -R $REF_FILE \
    -I ${BAM_FILE%%.bam}_realigned.bam \
    --genotyping_mode DISCOVERY \
    -ploidy 1 \
    -o raw_variants_HC.vcf
    # -L 20
