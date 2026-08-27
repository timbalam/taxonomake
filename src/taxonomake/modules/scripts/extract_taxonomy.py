import os.path
import polars as pl

GTDBTK_OUTPUT_DIRECTORY = snakemake.input["cla"]

# Read in taxons from GTDB-Tk
taxonomy_files = [
    f
    for f in (os.path.join(GTDBTK_OUTPUT_DIRECTORY, 'gtdbtk.bac120.summary.tsv'),
              os.path.join(GTDBTK_OUTPUT_DIRECTORY, 'gtdbtk.ar53.summary.tsv'))
    if os.path.exists(f)
]
d = pl.concat([
    pl
    .read_csv(f, separator = '\t')
    .select(pl.col('user_genome'), pl.col('classification'))
    for f in taxonomy_files
])
if "Unclassified" in d["classification"]:
    genomes = (d.filter(pl.col("classification") == "Unclassified"))["user_genome"]
    if len(genomes) > 5:
        genomes = genomes[:5] + [f" and {len(genomes) - 5} more"]
    raise Exception(";".join(genomes) + " were unclassified")

# Remove empty taxon strings because they mess up biobox creation
d = (
    d
    .with_columns(
        classification = pl.lit('Root;') +
            pl.col('classification')
            .str.replace(";s__$", "")
            .str.replace(";g__$", "")
            .str.replace(";f__$", "")
            .str.replace(";o__$", "")
            .str.replace(";c__$", "")
            .str.replace(";p__$", "")
    )
)

d.write_csv(snakemake.output["taxonomy"], separator = '\t', include_header = False)
