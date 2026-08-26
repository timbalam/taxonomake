import argparse
import logging
import os.path
import polars as pl

if __name__ == '__main__':
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--debug', help='output debug information', action="store_true")
    parser.add_argument('--quiet', help='only output errors', action="store_true")
    parser.add_argument('--gtdbtk-output-directory', help='GTDB-Tk output directory', required=True)
    parser.add_argument('-o', help='Output file')

    args = parser.parse_args()

    # Setup logging
    if args.debug:
        loglevel = logging.DEBUG
    elif args.quiet:
        loglevel = logging.ERROR
    else:
        loglevel = logging.INFO
    logging.basicConfig(level=loglevel, format='%(asctime)s %(levelname)s: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')

    # Read in taxons from GTDB-Tk
    taxonomy_files = [
        f
        for f in (os.path.join(args.gtdbtk_output_directory, 'gtdbtk.bac120.summary.tsv'),
                  os.path.join(args.gtdbtk_output_directory, 'gtdbtk.ar53.summary.tsv'))
        if os.path.exists(f)
    ]
    d = pl.concat([
        pl
        .read_csv(f, separator = '\t')
        .select(pl.col('user_genome'), pl.col('classification'), pl.lit(f).alias("source_file"))
        for f in taxonomy_files
    ])
    for row in d.group_by(pl.col('source_file')).agg(pl.len()).iter_rows(named = True):
        logging.info(f"Read {row['len']} taxonomies from {row['source_file']}")

    if "Unclassified" in d["classification"]:
        genomes = (d.filter(pl.col("classification") == "Unclassified"))["user_genome"]
        if len(genomes) > 5:
            genomes = genomes[:5] + [f" and {len(genomes) - 5} more"]
        raise Exception(";".join(genomes) + " were unclassified")

    # Remove empty taxon strings because they mess up biobox creation
    d = (
        d
        .drop(pl.col('source_file'))
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

    d.write_csv(args.o, separator = '\t', include_header = False)
