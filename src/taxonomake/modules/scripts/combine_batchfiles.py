from taxonomake.modules.scripts.simulate_art import read_genomes_list
import polars as pl

(
    pl
    .concat([read_genomes_list(f) for f in snakemake.input["genomes_lists"]])
    .write_csv(snakemake.output['batchfile'], separator = '\t', include_header = False)
)