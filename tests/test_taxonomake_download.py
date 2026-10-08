
import os
import extern
import pytest

path_to_data = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'data')

@pytest.mark.skipif(not os.path.exists(f"{path_to_data}/tmp/gtdbtk_r207_v2_data"), reason="gtdbtk data not downloaded")
def test_taxonomake_gtdbtk_r207():
    # Check that it is pre-downloaded and doesn't re-download
    cmd = f"taxonomake --download {path_to_data}/community_gtdbtk_r207.yaml"
    extern.run(cmd)
    assert os.path.isdir(f"{path_to_data}/tmp/gtdbtk_r207_v2_data")

@pytest.mark.skipif(not os.path.exists(f"{path_to_data}/tmp/gtdbtk_r226_data"), reason="gtdbtk data not downloaded")
def test_taxonomake_gtdbtk_r226():
    # Check that it is pre-downloaded and doesn't re-download
    cmd = f"taxonomake --download {path_to_data}/community_gtdbtk_r226.yaml"
    extern.run(cmd)
    assert os.path.isdir(f"{path_to_data}/tmp/gtdbtk_r226_data")

@pytest.fixture
def end_to_end_accessions_genomes():
    files_to_remove = [
        f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna",
        f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna"
    ]
    def cleanup():
        for file in files_to_remove:
            try:
                os.remove(file)
            except FileNotFoundError:
                pass
    
    cleanup()
    yield
    cleanup()

@pytest.mark.expensive
def test_taxonomake_genomes_accession(end_to_end_accessions_genomes):
    cmd = f"taxonomake --download {path_to_data}/community_genomes_accession.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna")
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna")

@pytest.mark.expensive
def test_taxonomake_genomes_taxon(end_to_end_accessions_genomes):
    cmd = f"taxonomake --download {path_to_data}/community_genomes_taxon.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna")
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna")