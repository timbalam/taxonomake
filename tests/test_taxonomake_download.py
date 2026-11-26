import os
import extern
import pytest

path_to_data = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'data')

@pytest.mark.skipif(not os.path.exists(f"{path_to_data}/tmp/gtdbtk_r207_v2_data"), reason="gtdbtk data not downloaded")
def test_taxonomake_gtdbtk_r207_predownload():
    """Test that pre-downloaded r207 data doesn't re-download"""
    cmd = f"taxonomake --download {path_to_data}/community_gtdbtk_r207.yaml"
    extern.run(cmd)
    assert os.path.isdir(f"{path_to_data}/tmp/gtdbtk_r207_v2_data")

@pytest.mark.skipif(not os.path.exists(f"{path_to_data}/tmp/gtdbtk_r226_data"), reason="gtdbtk data not downloaded")
def test_taxonomake_gtdbtk_r226_predownloaded():
    """Test that pre-downloaded r226 data doesn't re-download"""
    cmd = f"taxonomake --download {path_to_data}/community_gtdbtk_r226.yaml"
    extern.run(cmd)
    assert os.path.isdir(f"{path_to_data}/tmp/gtdbtk_r226_data")

@pytest.fixture
def end_to_end_accessions():
    """Remove genomes downloaded by community_accession_download.yaml"""
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

@pytest.fixture
def end_to_end_virus_accessions():
    """Remove virus genomes downloaded by community_virus_accession_download.yaml"""
    files_to_remove = [
        f"{path_to_data}/tmp/viruses/NC_000935.1_genomic.fna",
        f"{path_to_data}/tmp/viruses/NC_001420.2_genomic.fna"
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
def test_taxonomake_accession(end_to_end_accessions):
    """Test downloading genomes by accession ids"""
    cmd = f"taxonomake --download {path_to_data}/community_accession_download.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna")
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna")

@pytest.mark.expensive
def test_taxonomake_taxon(end_to_end_accessions):
    """Test downloading genomes by taxid ids"""
    cmd = f"taxonomake --download {path_to_data}/community_taxon_download.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_000309865.1_genomic.fna")
    assert os.path.isfile(f"{path_to_data}/tmp/genomes/GCA_002067065.1_genomic.fna")

@pytest.mark.expensive
def test_taxonomake_viruses_accession(end_to_end_virus_accessions):
    """Test downloading virus genomes by accession ids"""
    cmd = f"taxonomake --download {path_to_data}/community_virus_accession_download.yaml"
    extern.run(cmd)
    assert os.path.isfile(f"{path_to_data}/tmp/viruses/NC_000935.1_genomic.fna")
    assert os.path.isfile(f"{path_to_data}/tmp/viruses/NC_001420.2_genomic.fna")