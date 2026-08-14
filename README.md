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
and input files. A minimal configuration would look like:

```yaml
# truth.tsv has columns sample/taxonomy/coverage
truth: "truth.tsv"

samples:
  small: { reads1: "tmp/small_1.fq.gz", reads2: "tmp/small_2.fq.gz" }
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
  tool: "art"
  binary: "art_illumina"
  read_length: 150
```

See below for field descriptions.


## Configfile options

`truth`
- path to a tsv with columns named `sample`, `taxonomy`, `coverage`.
  True taxonomic profile.

`samples`
- object with fields corresponding to sample names.
  Values are objects describing samples
  which are collections of either single- or paired-end reads.
  For single-ended reads, objects contain one field:
  
  `reads`
  - path to reads in fastq format

  For paired-ended reads, objects have two fields:

  `reads1`
  - list of paths to forward reads in fastq format.

  `reads2`
  - list of paths to reverse reads in fastq format.

`taxonomy`
- path to a tsv with two (unnamed) columns 
  containing 1. OTU identifiers,
  and 2. semi-colon separated taxonomy strings.

`genomes_list`
- path to a tsv with two (unnamed) columns
  containing 1. paths to genome sequences in fasta format,
  and 2. OTU identifiers.

`readsim`
- object describing configuration of tool to use for read simulation.
  Currently 'art' is the only supported tool.

  An 'art' configuration object contains the following fields:
  
  `tool`
  - name of tool: 'art'.

  Describes configuration of read-simulation tool
  for simulating samples. 
  
