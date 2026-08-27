
import os
import logging
import subprocess
import shutil
import sys
from ruamel.yaml import YAML
import shlex
from snakemake.utils import validate

SNAKEFILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Snakefile")
DOWNLOAD_SNAKEFILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "download.smk")
SCHEMA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.schema.yaml")

def process_community_description(file, *, prefix, cores = 8, snakemake_args, download = False):
    yaml = YAML()
    with open(file) as f:
        conf = yaml.load(f)
    validate(conf, SCHEMA)
    cmd = [
        shutil.which("snakemake"),
        "--snakefile",
        DOWNLOAD_SNAKEFILE if download else SNAKEFILE,
        "--directory",
        f"{prefix}",
        "--rerun-incomplete",
        "--keep-going",
        "--configfile",
        f"{file}", 
        "--nolock",
        "--cores",
        f"{cores}",
        "--config",
        f"configfilepath={os.path.abspath(file)}",
        "--",
        "all"
    ]
    if snakemake_args != "":
        cmd += shlex.split(snakemake_args)

    logging.debug(f"Command: {shlex.join(cmd)}")
    logging.info("Executing: %s" % shlex.join(cmd))
    proc = subprocess.Popen(
        cmd,
        #shell=True,
        #stdout=subprocess.PIPE,
        #stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
        bufsize=1
    )
    
    proc.wait()

    #for line in proc.stdout:
    #     sys.stdout.write(line)
    #     sys.stdout.flush()
    
    # for line in proc.stderr:
    #     sys.stderr.write(line)
    #     sys.stderr.flush()
    
    if proc.returncode == 0:
        logging.info("Finished")
    else:
        sys.exit(1)
