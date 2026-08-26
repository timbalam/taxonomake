import os.path
from taxonomake.modules.common import (
    config_classify_dir,
    config_classify_data,
    config_genomes_list,
    config_taxonomy
)

SIM_SCRIPTS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(workflow.snakefile))), 'scripts')
MANIFEST_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(workflow.snakefile))), 'pixi.toml')

rule extract_taxonomy_gtdbtk_r207:
    output:
        taxonomy=config_taxonomy(config)
    input:
        gtdbtk_output_dir=config_classify_dir(config, 'classify')
    log:
        "logs/gtdbtk/r207/taxonomy.log"
    shell:
        f"python3 {SIM_SCRIPTS_DIR}/extract_taxonomy.py " \
        "--gtdbtk-output-directory {input.gtdbtk_output_dir} " \
        "-o {output.taxonomy} &> {log}"

# release 207
rule download_gtdbtk_r207_data:
    output:
        config_classify_dir(config, 'gtdbtk_r207_v2_data.tar.gz')
    log:
        "logs/gtdbtk_r207_data-download.log"
    shell:
        "bash -c "\
        "'cd " + config_classify_dir(config) + " && "\
        "wget https://data.gtdb.ecogenomic.org/releases/release207/207.0/auxillary_files/gtdbtk_r207_v2_data.tar.gz' &> {log}"

rule extract_gtdbtk_r207_data:
    input:
        config_classify_dir(config, "gtdbtk_r207_v2_data.tar.gz")
    output:
        directory(config_classify_data(config))
    log:
        "logs/gtdbtk_r207_v2_data-extract.log"
    shell:
        "bash -c " \
        "'cd " + config_classify_dir(config) + " && " \
        "tar -xzf gtdbtk_r207_v2_data.tar.gz && " +
        "mv release207_v2 " + config_classify_data(config) + "' &> {log}"

rule genome_accessions_download:
    input:
        genomes_list=config_genomes_list(config),
        accessions=config_classify_dir(config, "genome_accessions.txt"),
        ncbi_names=config_classify_dir(config, "genome_ncbi_names.tsv")
    output:
        done=touch(config_classify_dir(config, "genomes-download.done"))
    log:
        "logs/genomes_download.log"
    shell:
        "test -s {input.accessions} && " \
        "bash -c " \
        "'cd " + config_classify_dir(config, "genomes") + " && " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e datasets " \
        "datasets download genome accession --inputfile {input.accessions} && " \
        "unzip ncbi_dataset.zip && " \
        "parallel --col-sep \"\\t\" mv {1} {2} :::: {output.ncbi_names}' &> {log}"

rule genome_accessions_to_download:
    input:
        genomes_list=config_genomes_list(config)
    output:
        accessions=config_classify_dir(config, "genome_accessions.txt"),
        ncbi_names=config_classify_dir(config, "genome_ncbi_names.tsv")
    params:
        genomes_list_dir=lambda wildcards, input: os.path.dirname(input.genomes_list),
        genomes_list_base=lambda wildcards, input: os.path.basename(input.genomes_list)
    shell:
        "bash -c " \
        "'cd {params.genomes_list_dir} && " \
        "while read IFS=\"\\t\" otu file; " \
        "do [ -e \"$file\" ] || echo \"ncbi_dataset/data/$otu/*_genomic.fna\\t$otu\"; " \
        "done < {params.genomes_list_base} > {output.ncbi_names}' && " \
        "cut -f2 {output.ncbi_names} > {output.accessions}"

rule gtdbtk_r207_identify:
    input:
        genomes_list=config_genomes_list(config),
        genomes_downloaded=config_classify_dir(config, "genomes-download.done"),
        data_path=config_classify_data(config)
    output:
        output_dir=directory(config_classify_dir(config, "identify")),
        done=touch(config_classify_dir(config, "identify.done"))
    log:
        "logs/gtdbtk/r207/identify.log"
    params:
        # run gtdbtk in directory of genomes_list
        # so paths are interpreted relative to the file location
        genomes_list_dir=lambda wildcards, input: os.path.dirname(input.genomes_list),
        genomes_list_base=lambda wildcards, input: os.path.basename(input.genomes_list)
    shell:
        "bash -c " \
        "'cd {params.genomes_list_dir} && " \
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e gtdbtk-r207 " \
        "gtdbtk identify --batchfile {params.genomes_list_base} " \
        "--out_dir {output.output_dir} " \
        "--extension .fasta' " \
        "&> {log}"

rule gtdbtk_r207_align:
    input:
        id=config_classify_dir(config, "identify"),
        data_path=config_classify_data(config)
    output:
        output_dir=directory(config_classify_dir(config, "align")),
        done=touch(config_classify_dir(config, "align.done"))
    log:
        "logs/gtdbtk/r207/align.log"
    shell:
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e gtdbtk-r207 " \
        "gtdbtk align --identify_dir {input.id} " \
        "--out_dir {output.output_dir} " \
        "&> {log}"

rule gtdbtk_r207_classify:
    input:
        genomes_list = config_genomes_list(config),
        genomes_downloaded=config_classify_dir(config, "genomes-download.done"),
        al = config_classify_dir(config, "align"),
        data_path = config_classify_data(config)
    output:
        output_dir = directory(config_classify_dir(config, "classify")),
        done=touch(config_classify_dir(config, "classify.done"))
    log:
        "logs/gtdbtk/r207/classify.log"
    resources:
        mem_mb=64000
    params:
        # run gtdbtk in directory of genomes_list
        # so paths are interpreted relative to the file location
        genomes_list_dir=lambda wildcards, input: os.path.dirname(input.genomes_list),
        genomes_list_base=lambda wildcards, input: os.path.basename(input.genomes_list)
    shell:
        "bash -c " \
        "'cd {params.genomes_list_dir} && " \
        "GTDBTK_DATA_PATH={input.data_path} " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e gtdbtk-r207 " \
        "gtdbtk classify --batchfile {params.genomes_list_base} " \
        "--align_dir {input.al} " \
        "--extension .fasta " \
        #"--scratch_data " \
        "--out_dir {output.output_dir}' " \
        "&> {log}"
