
import os
import extern
import shutil
import pytest

path_to_data = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'data')

@pytest.fixture
def end_to_end_gtdbtk():
    def cleanup():
        try:
            shutil.rmtree(f"{path_to_data}/tmp/gtdbtk_r207_v2_data")
        except FileNotFoundError:
            pass
    
    cleanup()
    yield
    cleanup()

@pytest.mark.expensive
def test_taxonomake_gtdbtk_r207(end_to_end_gtdbtk):
    cmd = f"taxonomake --download {path_to_data}/community_gtdbtk_r207.yaml"
    extern.run(cmd)
    assert os.path.isdir(f"{path_to_data}/tmp/gtdbtk_r207_v2_data")

@pytest.fixture
def end_to_end_gtdbtk():
    def cleanup():
        try:
            os.remove(f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna")
        except FileNotFoundError:
            pass
        try:
            os.remove(f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna")
        except FileNotFoundError:
            pass
    
    cleanup()
    yield
    cleanup()

@pytest.mark.expensive
def test_taxonomake_ncbi_genomes(end_to_end_gtdbtk):
    cmd = f"taxonomake --download {path_to_data}/community_ncbi_genomes.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna")
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna")