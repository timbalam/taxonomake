import os
import extern
import shutil
import pytest
import polars as pl

path_to_data = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'data')

@pytest.fixture
def end_to_end():
    def cleanup():
        try:
            os.remove(f"{path_to_data}/tmp/small_1.fq.gz")
        except FileNotFoundError:
            pass
        try:
            os.remove(f"{path_to_data}/tmp/small_2.fq.gz")
        except FileNotFoundError:
            pass
    
    cleanup()
    yield
    cleanup()

def assert_equal_tsv(old, new, *, separator = '\t', **args):
    olddf = pl.read_csv(old, separator = separator, **args)
    newdf = pl.read_csv(new, separator = separator, **args)
    assert set(olddf.columns) == set(newdf.columns)
    assert olddf.select(pl.col(newdf.columns)).sort() == newdf.sort()


def test_taxonomake(end_to_end):
    cmd = f"taxonomake {path_to_data}/community.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/small_1.fq.gz")
    assert os.path.isfile(f"{path_to_data}/tmp/small_2.fq.gz")
    assert_equal_tsv(f"{path_to_data}/truth.tsv", f"{path_to_data}/tmp/truth.tsv")

def test_taxonomake2(end_to_end):
    cmd = f"taxonomake {path_to_data}/community2.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/small_1.fq.gz")
    assert os.path.isfile(f"{path_to_data}/tmp/small_2.fq.gz")
    assert_equal_tsv(f"{path_to_data}/truth.tsv", f"{path_to_data}/tmp/truth.tsv")

@pytest.fixture
def end_to_end_gtdbtk():
    def cleanup():
        try:
            os.remove(f"{path_to_data}/tmp/small_1.fq.gz")
        except FileNotFoundError:
            pass
        try:
            os.remove(f"{path_to_data}/tmp/small_2.fq.gz")
        except FileNotFoundError:
            pass
        try:
            shutil.rmtree(f"{path_to_data}/tmp/genomes.gtdbtk_r207")
        except FileNotFoundError:
            pass
    
    cleanup()
    yield
    cleanup()

@pytest.mark.skipif(not os.path.exists(f"{path_to_data}/tmp/gtdbtk_r207_v2_data"), reason="gtdbtk data not downloaded")
@pytest.mark.expensive
def test_taxonomake_gtdbtk_r207(end_to_end_gtdbtk):
    cmd = f"taxonomake {path_to_data}/community_gtdbtk_r207.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/small_1.fq.gz")
    assert os.path.isfile(f"{path_to_data}/tmp/small_2.fq.gz")
