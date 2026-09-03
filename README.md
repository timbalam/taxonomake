# Taxonomic profile maker

Taxonomake is a tool for generating simulated datasets
with known composition for benchmarking.

# Usage

```bash
taxonomake [configfile]
```

# Configfile

Taxonomake is configured by a configuration yaml. 
The configuration yaml defines output, intermediate
and input files. If an existing file is specified
it will be used as an input,
otherwise Taxonomake will try to create
the files from other inputs where possible.

Configurations for the main use cases are described next.
Detailed descriptions of options can be found in 'Configfile options' below.

## Final outputs

The minimal configuration below
demonstrates Taxonomake's final outputs -
a ground truth profile
and a corresponding set files of of paired reads
from a sample.

```yaml
# truth.tsv has columns sample/taxonomy/coverage
truth: "truth.tsv"

samples:
  names: ['small'],
  reads1: ["tmp/small_1.fq.gz"],
  reads2: ["tmp/small_2.fq.gz"]
```

## Compute truth

With some additional configuration shown below
Taxonomake can generate a missing truth profile `truth`
from input files containing genome-wise coverages
per sample `coverages`
and corresponding genome taxonomies `taxonomy`.

```yaml
# coverage.tsv has otu/coverage
coverages:
  small: "coverage.tsv"

# taxonomy.tsv has otu/taxonomy
taxonomy: "taxonomy.tsv"
```

## Simulate reads

Taxonomake can generate any missing reads files
defined in `samples` by simulation
using the genomes from the input `genomes_list` file
so that the corresponding samples
have the coverages defined by `coverages`.
The configuration below demonstrates
using the simulation tool 'art'
(the binary name 'art_illumina' is required to be located on PATH).

```yaml
# genomes.tsv has path_to_fna/otu
genomes_list: "genomes.tsv"

readsim:
  art:
    binary: "art_illumina"
    read_length: 150
```

## Classify genomes

The above configuration relies on the genomes from  `genomes_list`
having known taxonomy defined in the `taxonomy` tsv file.
With additional configuration,
Taxonomake can create a missing `taxonomy` tsv file
by assigning taxonomy to the genomes, as demonstrated below
using the Genome Tree Database Toolkit (GTDB-TK)
release 207.

```yaml
classify:
  gtdbtk:
    release: "207"
    directory: "tmp/genomes.gtdbtk_r207"
    data: "tmp/gtdbtk_r207_v2_data"
```

## Configfile options

`truth`
- Path to a tsv with columns named `sample`, `taxonomy`, `coverage`.
  True taxonomic profile.

`samples`
- Object with three fields:
  `names`
  - List of names of samples.

  `reads1`
  - List of paths to forward reads in fastq format.

  `reads2`
  - List of paths to reverse reads in fastq format.

  Describes samples,
  which are collections of paired-end reads.

`coverages`
- Object with field names corresponding to sample names
  and values corresponding to paths to tsv with two (unnamed) columns
  containing 1. OTU identifiers, and 2. coverages.

`taxonomy`
- Path to a tsv with two (unnamed) columns 
  containing 1. OTU identifiers,
  and 2. semi-colon separated taxonomy strings.

`genomes_list`
- Path to a tsv with two (unnamed) columns
  containing 1. paths to genome sequences in fasta format,
  and 2. OTU identifiers.

`readsim`
- Object with one of the following fields:
  describing configuration of tool to use for read simulation.
  Currently 'art' is the only supported tool.

  An 'art' configuration object contains the following fields:
  
  `tool`
  - Name of tool: 'art'.

  Describes configuration of read-simulation tool
  for simulating samples. 

`gtdbtk`
- Object 
  release: "207"
  directory: "tmp/genomes.gtdbtk_r207"
  data: "tmp/gtdbtk_r207_v2_data"
