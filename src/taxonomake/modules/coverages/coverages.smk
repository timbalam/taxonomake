from taxonomake.modules.common import (
    config_truths,
    config_sample_names,
    config_coverages,
    config_genomes_lists,
    config_taxonomy,
    get_script
)

rule coverages_to_truth:
    input:
        coverages_files = list(config_coverages(config)),
        genomes_lists = list(config_genomes_lists(config).values()),
        taxonomy = config_taxonomy(config)
    output:
        truths = sorted(set(config_truths(config)))
    localrule: True
    params:
        sample_names = list(config_sample_names(config))
    script:
        get_script("sum_coverages.py")
