from taxonomake.modules.common import (
    config_classify_dir,
    config_classify_data,
    config_classify_gtdbtk_release,
    config_genomes_lists,
    config_taxonomy,
    get_script,
    MANIFEST_PATH
)

RELEASE = config_classify_gtdbtk_release(config)
LOG_DIR = f"logs/gtdbtk/r{RELEASE}"
PIXI_ENV = {
    "207": "gtdbtk-r207",
    "226": "gtdbtk-r226"
}[RELEASE]

rule extract_taxonomy_gtdbtk:
    output:
        taxonomy = config_taxonomy(config)
    input:
        cla = config_classify_dir(config, 'classify')
    log:
        f"{LOG_DIR}/taxonomy.log"
    localrule: True
    script:
        get_script("extract_taxonomy.py")

rule gtdbtk_identify:
    input:
        batchfile = "batchfile.tsv",
        data_path = config_classify_data(config)
    output:
        output_dir = directory(config_classify_dir(config, "identify")),
        done = touch(config_classify_dir(config, "identify.done"))
    log:
        f"{LOG_DIR}/identify.log"
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e {PIXI_ENV} " \
        "gtdbtk identify --batchfile {input.batchfile} " \
        "--out_dir {output.output_dir} " \
        "--extension .fasta &> {log}"

rule gtdbtk_batch_file:
    input:
        genomes_lists = list(config_genomes_lists(config).values())
    output:
        batchfile = "batchfile.tsv"
    localrule: True
    script:
        get_script("combine_batchfiles.py")

rule gtdbtk_align:
    input:
        iden = config_classify_dir(config, "identify"),
        data_path = config_classify_data(config)
    output:
        output_dir = directory(config_classify_dir(config, "align")),
        done = touch(config_classify_dir(config, "align.done"))
    log:
        f"{LOG_DIR}/align.log"
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e {PIXI_ENV} " \
        "gtdbtk align --identify_dir {input.iden} " \
        "--out_dir {output.output_dir} " \
        "&> {log}"

rule gtdbtk_r207_classify:
    input:
        batchfile = "batchfile.tsv",
        al = config_classify_dir(config, "align"),
        data_path = config_classify_data(config)
    output:
        output_dir = directory(config_classify_dir(config, "classify")),
        done=touch(config_classify_dir(config, "classify.done"))
    log:
        f"{LOG_DIR}/classify.log"
    resources:
        mem_mb=64000
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e {PIXI_ENV} " \
        "gtdbtk classify --batchfile {input.batchfile} " \
        "--align_dir {input.al} " \
        "--extension .fasta " \
        #"--scratch_data " \
        "--out_dir {output.output_dir} &> {log}"
