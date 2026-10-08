import os.path
from taxonomake.modules.common import (
    config_genomes_accession_list,
    config_taxonomy,
    MANIFEST_PATH,
    get_script
)

rule download_accession_genomes:
    input:
        accessions="ncbi/genome_accessions.txt",
        ncbi_names="ncbi/accession_genome_ncbi_names.tsv"
    output:
        done=touch("accession_genomes-download.done")
    log:
        "logs/accession_genomes-download.log"
    localrule: True
    shell:
        "if test -s {input.accessions}; then " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e datasets " \
        "datasets download genome accession --inputfile {input.accessions} && " \
        "{{ rm -r ncbi_dataset README.md md5sum.txt; unzip ncbi_dataset.zip; }} && " \
        "{{ " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " \
        "parallel --col-sep '\\t' dirname {{2}} :::: {input.ncbi_names} | "
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " \
        "parallel mkdir -p;  " \
        "}} && " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " \
        "parallel --col-sep '\\t' mv {{1}}/*.fna {{2}} :::: {input.ncbi_names}; " \
        "fi &> {log}"

rule accessions_to_download:
    input:
        genomes_list=config_accession_genomes_list(config)
    output:
        ncbi_ids="ncbi/genome_accessions.txt",
        ncbi_names="ncbi/accession_genome_ncbi_names.tsv"
    localrule: True
    script:
        get_script("genomes_to_download.py")
