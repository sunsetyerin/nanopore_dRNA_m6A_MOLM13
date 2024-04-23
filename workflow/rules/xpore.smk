# -*- coding: utf-8 -*-

##### Imports #####

# Std lib
from pathlib import Path

module_name="xpore"

if config["gpu_acceleration"]:
    f5c_container="library://aleg/default/f5c:gpu-0.6"
else:
    f5c_container="library://aleg/default/f5c:cpu-0.6"

# we have to do an extra eventalign because xpore needs read_index instead of read_name
rule_name="xpore_eventalign"
rule xpore_eventalign:
    input:
        fastq=rules.merge_fastq.output.fastq,
        index=rules.f5c_index.output.index,
        bam=rules.alignmemt_postfilter.output.bam,
        fasta=rules.get_transcriptome.output.fasta,
        kmer_model="resources/f5c/r9.4_70bps.u_to_t_rna.5mer.template.model"
    output:
        tsv=join("results", module_name, rule_name, "{cond}_{rep}_data.tsv"),
        summary=join("results", module_name, rule_name, "{cond}_{rep}_summary.tsv")
    log:
        join("logs", module_name, rule_name, "{cond}_{rep}.log")
    threads: 
        get_threads(config, rule_name)
    params:
        opt=get_opt(config, rule_name)
    resources:
        mem_mb=get_mem(config, rule_name)
    container:
        f5c_container
    shell:  "f5c eventalign {params.opt} -t {threads} --kmer-model {input.kmer_model} -r {input.fastq} -b {input.bam} -g {input.fasta} --summary {output.summary}  > {output.tsv} 2> {log}"


rule_name="xpore_dataprep"
rule xpore_dataprep:
    input:
        eventalign=rules.xpore_eventalign.output.tsv,
    output:
        data=multiext(
            str(join("results", module_name, rule_name, "{cond}_{rep}/data")), 
            ".index",
            ".json",
            ".log",
            ".readcount",
        ),
        idx=join("results", module_name, rule_name, "{cond}_{rep}/eventalign.index"),
    log:
        join("logs", module_name, rule_name, "{cond}_{rep}.log")
    threads:
        get_threads(config, rule_name)
    params:
        opt=get_opt(config, rule_name),
        outdir=lambda wildcards, output: Path(output.idx).parent,
    resources:
        # mem_mb=lambda wildcards, attempt: attempt * 8 * GB,
        mem_mb=get_mem(config, rule_name),
        time="1d",
    container:
        "docker://quay.io/biocontainers/xpore:2.1--pyh5e36f6f_0"
    shell:  "xpore dataprep {params.opt} --eventalign {input.eventalign} \
            --n_processes {threads} --out_dir {params.outdir} 2> {log}"


rule_name="xpore_config"
rule xpore_config:
    input:
        control_json=expand(join("results", module_name, "xpore_dataprep", "control_{rep}/data.json"),rep=replicates_list),
        # test_json=expand(join("results", module_name, "xpore_dataprep", "test_{rep}/data.json"),rep=replicates_list),
        test_json=expand(join("results", module_name, "xpore_dataprep", "cnot3_test_{rep}/data.json"),rep=replicates_list),
    output:
        # configuration=join("results", module_name, rule_name, "xpore_config.yaml"),
        configuration=join("results", module_name, rule_name, "xpore_cnot3_config.yaml"),
    params:
        readcount_min=15,
        readcount_max=1_000,
        # outdir=join("results", module_name, "xpore_diffmod"),
        outdir=join("results", module_name, "xpore_cnot3_diffmod"),
    resources:
        time="5m",
    log: 
        join("logs",module_name, rule_name, "xpore_cnot3_config.log")
    conda:
        f"../../envs/xpore_config.yaml"
    script: 
        # f"../scripts/xpore_config.py" # METTL3 KD vs WT
        f"../scripts/xpore_cnot3_config.py" # CNOT3 KD vs WT

rule_name="xpore_diffmod"
rule xpore_diffmod:
    input:
        configuration=rules.xpore_config.output.configuration,
    output:
        # table=join("results", module_name, rule_name, "diffmod.table"),
        # log=join("results", module_name, rule_name, "diffmod.log"),
        table=join("results", module_name, "xpore_cnot3_diffmod", "diffmod.table"),
        log=join("results", module_name, "xpore_cnot3_diffmod", "diffmod.log"),
    log:
        # join("logs", module_name, rule_name, "xpore_diffmod.log"),
        join("logs", module_name, rule_name, "xpore_cnot3_diffmod.log"),
    threads: 10
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 8000,
        time="1h",
    container:
        "docker://quay.io/biocontainers/xpore:2.1--pyh5e36f6f_0"
    shell:
        "xpore diffmod --config {input.configuration} --n_processes {threads} 2> {log}"
