from taxonomake.modules.scripts.simulate_art import read_genomes_list
import polars as pl
import os.path

df = (
    read_genomes_list(snakemake.input["genomes_list"])
    .filter(
        pl.col("path").map_elements(os.path.exists).not_()
    )
    .with_columns(
        download = pl.lit("ncbi_dataset/data/") + pl.col("otu")
    )
)

df.select(pl.col("download"), pl.col("path")).write_csv(snakemake.output["ncbi_names"], separator = '\t', include_header = False)
df.select(pl.col("otu")).write_csv(snakemake.output["accessions"], include_header = False)
