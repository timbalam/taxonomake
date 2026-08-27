from taxonomake.modules.common import (
    config_classify_dir,
    config_classify_data
)

# release 207
rule download_gtdbtk_r207_data:
    output:
        'gtdbtk_r207_v2_data.tar.gz'
    log:
        "logs/gtdbtk_r207_data-download.log"
    shell:
        "wget https://data.gtdb.ecogenomic.org/releases/release207/207.0/auxillary_files/gtdbtk_r207_v2_data.tar.gz &> {log}"

rule extract_gtdbtk_r207_data:
    input:
        "gtdbtk_r207_v2_data.tar.gz"
    output:
        directory(config_classify_data(config))
    log:
        "logs/gtdbtk_r207_v2_data-extract.log"
    shell:
        "tar -xzf gtdbtk_r207_v2_data.tar.gz && " +
        "mv release207_v2 " + config_classify_data(config) + " &> {log}"
