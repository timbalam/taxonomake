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
and input files. A minimal configuration could look like:

```yaml
# truth.tsv has columns sample/taxonomy/coverage
truth: "truth.tsv"

samples:
  names: ['small'],
  reads1: ["tmp/small_1.fq.gz"],
  reads2: ["tmp/small_2.fq.gz"]
```

## Simulated reads

This configuration is too minimal to be very useful,
as all Taxonomake can do is check if the described files exist.
More usefully, Taxonomake can generate samples if they are missing,
with a bit of additional configuration as demonstrated below.

```yaml
# taxonomy.tsv has otu/taxonomy
taxonomy: "taxonomy.tsv"

# genomes.tsv has otu/path_to_fna
genomes_list: "genomes.tsv"

readsim:
  art:
    binary: "art_illumina"
    read_length: 150
```

See below for field descriptions.
For the configuration above,
any reads files defined in `samples` that are missing
are simulated using the tool 'art'
(the binary name 'art_illumina' is required to be located on PATH),
using the genomes from the `genomes_list` file,
so that the resulting samples
have the taxonomic profile defined by `truth`.

## Taxonomic classification

The above configuration relies on the genomes from  `genomes_list`
having known taxonomy defined in the `taxonomy` tsv file.
With additional configuration,
Taxonomake can also assign taxonomy to the genomes
in cases where it is unknown, as demonstrated below:

```yaml
classify:
  gtdbtk:
    release: "207"
    directory: "tmp/genomes.gtdbtk_r207"
    data: "tmp/gtdbtk_r207_v2_data"
```

See below for field descriptions.
When the `taxonomy` tsv file designated
in the configuration is missing,
the above configuration will use
the Genome Tree Database Toolkit (GTDB-TK)
(currently only release 207 is supported)
to assign taxonomy to the genomes,
and create the tsv file.

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
