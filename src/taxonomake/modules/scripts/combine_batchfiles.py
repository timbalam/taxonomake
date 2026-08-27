from taxonomake.modules.common import read_genomes_list

(
    pl
    .concat([read_genomes_list(f) for f in snakemake.input["genomes_list"]])
    .write_csv(snakemake.output['batchfile'], separator = '\t', use_header = False)
)