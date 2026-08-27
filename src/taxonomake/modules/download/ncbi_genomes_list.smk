import os.path
from taxonomake.modules.common import (
    config_ncbi_genomes_list,
    config_taxonomy,
    MANIFEST_PATH,
    get_script
)

rule download_ncbi_genome_accessions:
    input:
        accessions="ncbi/genome_accessions.txt",
        ncbi_names="ncbi/genome_ncbi_names.tsv"
    output:
        done=touch("nbci_genomes_accessions-download.done")
    log:
        "logs/ncbi_genomes_accessions-download.log"
    shell:
        "if test -s {input.accessions}; then " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e datasets " \
        "datasets download genome accession --inputfile {input.accessions} && " \
        "{{ rm -r ncbi_dataset; unzip ncbi_dataset.zip }} && " \
        "{{ parallel --col-sep '\\t' dirname {{2}} :::: {input.ncbi_names} | parallel mkdir -p  }} && " \
        "parallel --col-sep '\\t' mv {{1}}/*.fna {{2}} :::: {input.ncbi_names}; " \
        "fi &> {log}"

rule genome_accessions_to_download:
    input:
        genomes_list=config_ncbi_genomes_list(config)
    output:
        accessions="ncbi/genome_accessions.txt",
        ncbi_names="ncbi/genome_ncbi_names.tsv"
    params:
        genomes_dir=lambda wildcards, input: os.path.dirname(input.genomes_list)
    script:
        get_script("genomes_accessions_to_download.py")
