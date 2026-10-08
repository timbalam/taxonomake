from taxonomake.modules.common import (
    config_classify_dir,
    config_classify_data,
    config_classify_gtdbtk_release
)

# release 207
rule download_gtdbtk_r207_data:
    output:
        'gtdbtk_r207_v2_data.tar.gz'
    log:
        "logs/gtdbtk_r207_data-download.log"
    localrule: True
    shell:
        "wget https://data.gtdb.ecogenomic.org/releases/release207/207.0/auxillary_files/gtdbtk_r207_v2_data.tar.gz &> {log}"

rule extract_gtdbtk_data:
    input:
        "gtdbtk_r207_v2_data.tar.gz"
    output:
        directory("release207_v2")
    log:
        "logs/gtdbtk_r207_v2_data-extract.log"
    shell:
        "tar -I pigz -xzf {input} &> {log}"

# release 226
rule download_gtdbtk_r226_data:
    output:
        'gtdbtk_r226_data.tar.gz'
    log:
        "logs/gtdbtk_r226_data-download.log"
    localrule: True
    shell:
        "wget 'https://data.gtdb.ecogenomic.org/releases/release226/226.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r226_data.tar.gz' &> {log}"

rule extract_gtdbtk_r226_data:
    input:
        "gtdbtk_r226_data.tar.gz"
    output:
        directory("release226")
    log:
        "logs/gtdbtk_r226_data-extract.log"
    shell:
        "unpigz < {input} | tar -x &> {log}"

GTDBTK_DATA = {
    '207': 'release207_v2',
    '226': 'release226'
}[config_classify_gtdbtk_release(config)]

rule move_gtdbtk_data:
    input:
        GTDBTK_DATA
    output:
        directory(config_classify_data(config))
    localrule: True
    shell:
        "mv {input} {output}"
