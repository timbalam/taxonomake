import shutil

for i, o in zip(snakemake.input, snakemake.output):
    shutil.move(i, o)
