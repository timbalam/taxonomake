from taxonomake.modules.common import (
    config_taxon_genomes_list,
    get_script
)

module common_genomes_list:
    snakefile: "common_genomes_list.smk"
    config: config

pathvars:
    type = "taxon",
    type_plural = "taxons"

use rule download_genomes from common_genomes_list as download_taxon_genomes with:
    params:
        download_opts = "genome taxon --assembly-level complete"
    pathvars:
        type = "taxon",
        type_plural = "taxons"


rule taxons_to_download:
    input:
        genomes_list=config_taxon_genomes_list(config)
    output:
        ncbi_ids="ncbi/genome_<type_plural>.txt",
        ncbi_names="ncbi/<type>_genome_ncbi_names.tsv"
    localrule: True
    script:
        get_script("genomes_to_download.py")
