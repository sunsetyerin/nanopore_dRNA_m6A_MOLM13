# -*- coding: utf-8 -*-

##### Imports #####

# Std lib
from os.path import join

##### Rules #####
module_name="nanopolish_polya"

rule_name="polya_result"
rule polya_result:
    input:
        fastq=rules.merge_fastq.output.fastq,
        index=rules.f5c_index.output.index,
        # bam=rules.alignmemt_postfilter.output.bam,
        # fasta=rules.get_transcriptome.output.fasta,
        bam=rules.minimap2_align.output.bam,
        fasta="/projects/ly_vu_direct_rna/MetaCompore/results/input/get_transcriptome/nanocompore_reference_transcriptome.fa",
    output:
        tsv=join("results", module_name, rule_name, "{cond}_{rep}_polya_result.tsv")
    log: 
        join("logs", module_name, rule_name, "{cond}_{rep}.log")
    threads: get_threads(config, rule_name)
    resources: mem_mb=get_mem(config, rule_name)
    container: "library://aleg/default/nanopolish:0.13.2"
    shell: "nanopolish polya --threads {threads} --reads {input.fastq} --bam {input.bam} --genome {input.fasta} > {output.tsv} 2> {log}"
