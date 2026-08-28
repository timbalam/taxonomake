from taxonomake.modules.common import (
    config_classify_data,
    config_has_ncbi_genomes_list,
    config_has_classify_data
)

download = []
if config_has_ncbi_genomes_list(config):
    module ncbi_genomes_list:
        snakefile: "download/ncbi_genomes_list.smk"
        config: config

    use rule * from ncbi_genomes_list

    download.append("nbci_genomes_accessions-download.done")

if config_has_classify_data(config):
    module gtdbtk_data:
        snakefile: "download/gtdbtk_data.smk"
        config: config
    
    use rule * from gtdbtk_data

    download.append(config_classify_data(config))

rule all:
    input:
        download
    localrule: True

