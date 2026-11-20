import os.path
from taxonomake.modules.common import (
    config_accession_genomes_list,
    get_script
)

module common_genomes_list:
    snakefile: "common_genomes_list.smk"
    config: config

pathvars:
    type = "accession",
    type_plural = "accessions"

use rule download_genomes from common_genomes_list as download_accession_genomes with:
    params:
        download_opts = "genome accession"

rule accessions_to_download:
    input:
        genomes_list=config_accession_genomes_list(config)
    output:
        ncbi_ids="ncbi/genome_<type_plural>.txt",
        ncbi_names="ncbi/<type>_genome_ncbi_names.tsv"
    localrule: True
    script:
        get_script("genomes_to_download.py")
