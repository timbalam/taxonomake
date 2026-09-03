from taxonomake.modules.common import (
    config_classify_dir,
    config_classify_data,
    config_genomes_lists,
    config_taxonomy,
    get_script,
    MANIFEST_PATH
)

rule extract_taxonomy_gtdbtk_r207:
    output:
        taxonomy = config_taxonomy(config)
    input:
        cla = config_classify_dir(config, 'classify')
    log:
        "logs/gtdbtk/r207/taxonomy.log"
    localrule: True
    script:
        get_script("extract_taxonomy.py")


rule gtdbtk_r207_identify:
    input:
        batchfile = "batchfile.tsv",
        data_path = config_classify_data(config)
    output:
        output_dir = directory(config_classify_dir(config, "identify")),
        done = touch(config_classify_dir(config, "identify.done"))
    log:
        "logs/gtdbtk/r207/identify.log"
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e gtdbtk-r207 " \
        "gtdbtk identify --batchfile {input.batchfile} " \
        "--out_dir {output.output_dir} " \
        "--extension .fasta &> {log}"

rule gtdbtk_r207_batch_file:
    input:
        genomes_lists = list(config_genomes_lists(config).values())
    output:
        batchfile = "batchfile.tsv"
    localrule: True
    script:
        get_script("combine_batchfiles.py")

rule gtdbtk_r207_align:
    input:
        iden = config_classify_dir(config, "identify"),
        data_path = config_classify_data(config)
    output:
        output_dir = directory(config_classify_dir(config, "align")),
        done = touch(config_classify_dir(config, "align.done"))
    log:
        "logs/gtdbtk/r207/align.log"
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e gtdbtk-r207 " \
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
        "logs/gtdbtk/r207/classify.log"
    resources:
        mem_mb=64000
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e gtdbtk-r207 " \
        "gtdbtk classify --batchfile {input.batchfile} " \
        "--align_dir {input.al} " \
        "--extension .fasta " \
        #"--scratch_data " \
        "--out_dir {output.output_dir} &> {log}"
