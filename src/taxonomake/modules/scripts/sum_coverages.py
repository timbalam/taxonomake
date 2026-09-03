import polars as pl
from taxonomake.modules.scripts.simulate_art import (
    read_coverage_file,
    read_genomes_list,
    read_taxonomy_file
)

def write_truth(*, coverages, genomes, taxonomy, output_truth):
    (
        coverages
        .join(genomes, on = 'otu', how = 'inner')
        .join(taxonomy, on = 'otu', how = 'inner')
        .group_by(pl.col('sample'), pl.col('taxonomy'))
        .agg(pl.col('coverage').sum())
        .write_csv(output_truth, separator = '\t')
    )

write_truth(
    coverages = pl.concat([
        read_coverage_file(f)
        .with_columns(sample = pl.lit(nm))
        for nm, f in zip(snakemake.params["sample_names"], snakemake.input["coverages_files"])
    ]),
    genomes = pl.concat([read_genomes_list(f) for f in snakemake.input["genomes_lists"]]),
    taxonomy = read_taxonomy_file(snakemake.input["taxonomy"]),
    output_truth = snakemake.output["truth"]
)