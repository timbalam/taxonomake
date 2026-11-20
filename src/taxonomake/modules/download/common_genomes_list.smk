from taxonomake.modules.common import MANIFEST_PATH

rule download_genomes:
    input:
        ncbi_ids="ncbi/genome_<type_plural>.txt",
        ncbi_names="ncbi/<type>_genome_ncbi_names.tsv"
    output:
        done=touch("<type>_genomes-download.done")
    log:
        "logs/<type>_genomes-download.log"
    localrule: True
    params:
        download_opts = ""
    shell:
        "if test -s {input.ncbi_ids}; then " \
        f"pixi run --manifest-path {MANIFEST_PATH} -e datasets " \
        "datasets download {params.download_opts} --inputfile {input.ncbi_ids} && " \
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
