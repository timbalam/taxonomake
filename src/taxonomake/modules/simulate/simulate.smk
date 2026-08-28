import os.path
from taxonomake.modules.common import (
    config_sample_reads1, config_sample_reads2, config_sample_names,
    config_truth, config_genomes_lists,
    config_taxonomy, config_readsim_bin,
    get_script, MANIFEST_PATH
)

#SIM_SCRIPTS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(workflow.snakefile))), 'scripts')
#MANIFEST_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(workflow.snakefile))), 'pixi.toml')

SIMULATE_ART_SCRIPT = get_script("simulate_art.py")
THREADS = 8

rule simulate_paired_reads_rename:
    input:
        r1 = ["readsim_" + config["readsim"]["tool"] + f"/{sample}_1.fq.gz" for sample in config_sample_names(config)],
        r2 = ["readsim_" + config["readsim"]["tool"] + f"/{sample}_2.fq.gz" for sample in config_sample_names(config)]
    output:
        r1 = config_sample_reads1(config),
        r2 = config_sample_reads2(config)
    localrule: True
#    script:
#        get_script("rename_all.py")
    shell:
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " \
        "parallel mv {{1}} {{2}} ::: {input.r1} {input.r2} :::+ {output.r1} {output.r2}"

rule simulate_art_paired_reads_sample:
    output:
        r1 = "readsim_art/{sample}_1.fq.gz",
        r2 = "readsim_art/{sample}_2.fq.gz"
    input:
        truth=config_truth(config),
        genomes_lists=list(config_genomes_lists(config).values()),
        taxonomy=config_taxonomy(config)
    params:
        art_bin=config_readsim_bin(config)
    threads: THREADS
    log: "logs/{sample}.log"
    shell:
        "mkdir -p readsim_art && " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e art " \
        f"python3 {SIMULATE_ART_SCRIPT} " \
        "--art {params.art_bin} " \
        "--threads {threads} " \
        "--coverage-file {input.truth} " \
        "--genome-lists {input.genomes_lists} " \
        "--taxonomy {input.taxonomy} " \
        "--sample {wildcards.sample} " \
        "-1 {output.r1} " \
        "-2 {output.r2} " \
        "2> {log}"