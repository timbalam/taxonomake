from taxonomake.modules.common import (
    config_classify_data,
    config_has_accession_genomes_list,
    config_has_taxon_genomes_list,
    config_has_classify_data
)

download = []
if config_has_accession_genomes_list(config):
    module accession_genomes_list:
        snakefile: "download/accession_genomes_list.smk"
        config: config

    use rule * from accession_genomes_list

    download.append("accession_genomes-download.done")

if config_has_taxon_genomes_list(config):
    module taxon_genomes_list:
        snakefile: "download/taxon_genomes_list.smk"
        config: config

    use rule * from taxon_genomes_list

    download.append("taxon_genomes-download.done")

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

