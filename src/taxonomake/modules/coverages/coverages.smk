from taxonomake.modules.common import (
    config_truth,
    config_coverages,
    config_genomes_lists,
    config_taxonomy,
    get_script
)

rule coverages_to_truth:
    input:
        coverages_files = list(config_coverages(config).values()),
        genomes_lists = list(config_genomes_lists(config).values()),
        taxonomy = config_taxonomy(config)
    output:
        truth = config_truth(config)
    localrule: True
    params:
        sample_names = list(config_coverages(config).keys())
    script:
        get_script("sum_coverages.py")
