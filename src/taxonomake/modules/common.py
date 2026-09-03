import os.path
import polars as pl
import importlib.resources

import taxonomake.modules.scripts
import taxonomake.modules
from taxonomake.modules.scripts.simulate_art import (
    _make_absolute
)

def get_script(*path):
    with importlib.resources.path(taxonomake.modules.scripts, *path) as fspath:
        ret = str(fspath)
    return ret

with importlib.resources.path(taxonomake.modules, "pixi.toml") as fspath:
    MANIFEST_PATH = str(fspath)
#SIM_SCRIPTS_DIR = importlib.resources.fios.path.join(os.path.dirname(os.path.dirname(os.path.abspath(workflow.snakefile))), 'scripts')
#MANIFEST_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(workflow.snakefile))), 'pixi.toml')


def _make_absolute_if_path(dir, path):
    return _make_absolute(dir, path) if os.path.dirname(path) != "" else path

def config_dir(config):
    return os.path.dirname(config["configfilepath"])

def config_sample_reads1(config):
    return [_make_absolute(config_dir(config), s) for s in config["samples"]["reads1"]]

def config_sample_reads2(config):
    return [_make_absolute(config_dir(config), s) for s in config["samples"]["reads2"]]

def config_sample_names(config):
    return config["samples"]["names"]

def config_truth(config):
    return _make_absolute(config_dir(config), config["truth"])

def config_coverages(config):
    return {k:_make_absolute(config_dir(config), v) for k, v in config["coverages"].items()}

def config_genomes_list(config):
    return config_genomes_lists(config)["user"]

def config_ncbi_genomes_list(config):
    return config_genomes_lists(config)["ncbi"]

def config_has_ncbi_genomes_list(config):
    return "genomes_list" in config and type(config["genomes_list"]) is not str and "ncbi" in config["genomes_list"]

def config_genomes_lists(config):
    dict = (
        {"user": config["genomes_list"]}
        if type(config["genomes_list"]) is str
        else config["genomes_list"]
    )
    return {k: _make_absolute(config_dir(config), v) for k, v in dict.items()}

def config_taxonomy(config):
    return _make_absolute(config_dir(config), config["taxonomy"])

def config_readsim_bin(config):
    return _make_absolute_if_path(config_dir(config), config["readsim"]["binary"])

def config_classify_dir(config, *paths):
    return _make_absolute(config_dir(config), config["classify"]["directory"], *paths)

def config_classify_data(config):
    return _make_absolute(config_dir(config), config["classify"]["data"])

def config_has_classify_data(config):
    return "classify" in config

def xread_genomes_list(path):
    dir = os.path.dirname(path)
    return (
        pl.read_csv(path, separator = '\t', has_header = False,
                    new_columns = ["path", "otu"])
        .with_columns(
            pl.col("path").map_elements(lambda path: _make_absolute(dir, path))
        )
    )