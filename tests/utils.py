import polars as pl
import polars.testing as plt


def assert_equal_tsv(old, new, *, separator = '\t', **args):
    olddf = pl.read_csv(old, separator = separator, **args)
    newdf = pl.read_csv(new, separator = separator, **args)
    plt.assert_frame_equal(olddf, newdf, check_column_order = False,
                           check_row_order = False)
