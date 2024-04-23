# -*- coding: utf-8 -*-

##### Imports #####

# Std lib
from pathlib import Path

module_name="m6anet"

rule_name="m6anet_dataprep"
rule m6anet_dataprep:
    input:
        eventalign=rules.f5c_eventalign.output.tsv, # WT vs CNOT3KD
        # eventalign=rules.f5c_eventalign.output.tsv, # WT vs METTL3
    output:
        data=multiext(
            str(join("results", module_name, "m6anet_dataprep2", "{cond}_{rep}/data")),
            ".json",
            ".info",
            ".log",
        ),
        idx=join("results", module_name, "m6anet_dataprep2", "{cond}_{rep}/eventalign.index"),
    log:
        join("logs", module_name, "m6anet_dataprep2", "{cond}_{rep}.log")
    threads:
        get_threads(config, rule_name)
    params:
        opt=get_opt(config, rule_name),
        outdir=lambda wildcards, output: Path(output.idx).parent,
    resources:
        # mem_mb=lambda wildcards, attempt: attempt * 8 * GB,
        mem_mb=get_mem(config, rule_name),
        time="1d",
    conda:
        "m6anet"
    shell:  "m6anet dataprep {params.opt} --eventalign {input.eventalign} \
            --n_processes {threads} --out_dir {params.outdir} 2> {log}"


# rule_name="m6anet_inference"
# rule m6anet_inference:
#     input:
#         # json_dir=expand(join("results", module_name, "m6anet_dataprep2", "{cond}_{rep}"), cond=condition_list, rep=replicates_list),
#         json_dir=expand(join("results", module_name, "m6anet_dataprep2", "cnot3_test_{rep}"), rep=replicates_list),
#         json_dir=expand(join("results", module_name, "m6anet_dataprep2", "control_{rep}"), rep=replicates_list),
#         # json_dir=expand(join("results", module_name, "m6anet_dataprep2", "test_{rep}"), rep=replicates_list),
#     output:
#         site_prob=join("results", module_name, "m6anet_inference2", "{cond}/data.site_proba.csv"),
#         indiv_prob=join("results", module_name, "m6anet_inference2", "{cond}/data.indiv_proba.csv"),
#         # site_prob=join("results", module_name, rule_name, "cnot3_test/data.site_proba.csv"),
#         # indiv_prob=join("results", module_name, rule_name, "cnot3_test/data.indiv_proba.csv"),
#     wildcard_constraints: 
#         cond="cnot3_test"
#         # cond="control"
#         # cond="test"
#     log:
#         join("logs", module_name, "m6anet_inference2", "{cond}.log"),
#     threads: 100
#     params:
#         outdir=lambda wildcards, output: Path(output.indiv_prob).parent,
#     resources:
#         mem_mb=lambda wildcards, attempt: attempt * 8000,
#         time="1h",
#     conda:
#         "m6anet"
#     shell: "m6anet inference --input_dir {input.json_dir} --out_dir {params.outdir} --batch_size 512 --n_processes {threads} --num_iterations 5 --device cpu 2> {log}"

rule_name="m6anet_inference_indiv"
rule m6anet_inference_indiv:
    input:
        json=join("results", module_name, "m6anet_dataprep2", "{cond}_{rep}/data.json")
    output:
        site_prob=join("results", module_name, "m6anet_inference_indiv2", "{cond}_{rep}/data.site_proba.csv"),
        indiv_prob=join("results", module_name, "m6anet_inference_indiv2", "{cond}_{rep}/data.indiv_proba.csv"),
    log:
        join("logs", module_name, "m6anet_inference_indiv2", "{cond}_{rep}.log")
    threads:
        100
    params:
        indir=lambda wildcards, input: Path(input.json).parent,
        outdir=lambda wildcards, output: Path(output.site_prob).parent,
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 8000,
        time="1h",
    conda:
        "m6anet"
    shell:  "m6anet inference --input_dir {params.indir} --out_dir {params.outdir} --batch_size 512 --n_processes {threads} --num_iterations 5 --device cpu 2> {log}"
