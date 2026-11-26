from taxonomake.modules.common import (
    config_virus_accession_genomes_list,
    MANIFEST_PATH,
    get_script
)

pathvars:
    type = "virus_accession",
    type_plural = "virus_accessions"

rule download_virus_accession_genomes:
    input:
        ncbi_ids="ncbi/genome_<type_plural>.txt",
        ncbi_names="ncbi/<type>_genome_ncbi_names.tsv"
    output:
        done=touch("<type>_genomes-download.done")
    log:
        "logs/<type>_genomes-download.log"
    localrule: True
    params:
        download_opts = "virus genome accession "
    shell:
        "if test -s {input.ncbi_ids}; then "
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel parallel "
        f"pixi run --manifest-path {MANIFEST_PATH} -e datasets "
        "datasets download {params.download_opts} --filename ncbi_dataset_{{1}}.zip {{1}} '&&' "
        "'{{' rm -r ncbi_dataset_{{1}}/'{{'ncbi_dataset,README.md,md5sum.txt'}};' " 
        "unzip ncbi_dataset_{{1}}.zip -d ncbi_dataset_{{1}}';' '}}' "
        " :::: {input.ncbi_ids} && "
        "{{ " 
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " 
        "parallel --col-sep '\\t' dirname {{2}} :::: {input.ncbi_names} | "
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " 
        "parallel mkdir -p;  " 
        "}} && " 
        f"pixi run --manifest-path {MANIFEST_PATH} -e parallel " 
        "parallel --col-sep '\\t' mv {{1}}/*.fna {{2}} :::: {input.ncbi_names}; " 
        "fi &> {log}"

rule virus_accessions_to_download:
    input:
        genomes_list=config_virus_accession_genomes_list(config)
    output:
        ncbi_ids="ncbi/genome_virus_accessions.txt",
        ncbi_names="ncbi/virus_accession_genome_ncbi_names.tsv"
    localrule: True
    script:
        get_script("virus_genomes_to_download.py")
