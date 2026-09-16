import polars as pl
from taxonomake.modules.scripts.simulate_art import (
    read_coverage_file,
    read_genomes_list,
    read_taxonomy_file
)

def write_truths(*, coverages, sample_names, genomes, taxonomy, output_truths):
    truths = (
        pl.concat([
            df.with_columns(sample = pl.lit(nm), output_truth = pl.lit(out))
            for df, nm, out in zip(coverages, sample_names, output_truths)
        ])
        .join(genomes, on = 'otu', how = 'inner')
        .join(taxonomy, on = 'otu', how = 'inner')
        .group_by(pl.col('sample', 'taxonomy', 'output_truth'))
        .agg(pl.col('coverage').sum())
    )
    for (file,), data in truths.group_by(pl.col('output_truth')):
        data.select(pl.col('sample', 'coverage', 'taxonomy')).write_csv(file, separator = '\t')

write_truths(
    coverages = [read_coverage_file(f) for f in snakemake.input["coverages_files"]],
    sample_names = snakemake.params["sample_names"],
    genomes = pl.concat([read_genomes_list(f) for f in snakemake.input["genomes_lists"]]),
    taxonomy = read_taxonomy_file(snakemake.input["taxonomy"]),
    output_truths = snakemake.params["truths_orig"]
)