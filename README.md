# Taxonomic profile maker

Taxonomake is a tool for generating simulated datasets
with known composition for benchmarking.

# Usage

```bash
taxonomake [configfile]
```

# Configfile

Taxonomake is configured by a configuration file in yaml format. 
The configuration file defines output, intermediate
and input files. If an existing file is specified
it will be used as an input,
otherwise Taxonomake will try to create
the files from other inputs where possible.

Configurations for the main use cases are described next.
Detailed descriptions of options can be found in 'Configfile options' below.

## (Non) Use case: I have everything I need.

Taxonomake is finished when the final outputs 
specified in the configuration are available -
a **ground truth profile**
and a sample described by a **name** and two files of **paired reads**.

```yaml
# truth.tsv has columns sample/taxonomy/coverage
truth: "truth.tsv"

samples:
  names: ['small']
  reads1: ["tmp/small_1.fq.gz"]
  reads2: ["tmp/small_2.fq.gz"]
```

## Use case: (Missing `truth`) I don't know the true profile, but I know the coverage and taxonomy of genomes in the samples.

A missing truth profile `truth` can be generated
if files containing **genome-wise coverages per sample** `coverages`
and corresponding **genome taxonomies** `taxonomy`
are specified in the configuration.

```yaml
# coverage.tsv has genome_id/coverage
sample_coverages: ["coverage.tsv"]

# taxonomy.tsv has genome_id/taxonomy
taxonomy: "taxonomy.tsv"
```

## Use case: (Missing `reads1`, `reads2`) I don't have sample reads, but I know the genome sequences and the coverages I want for the samples.

Missing paired reads files `reads1`, `reads2` defined in `samples` can be simulated
if a file containing paths to **genome sequences** `genomes_list`,
the file containing the **genome-wise coverages per sample** `coverages`,
and a simulation tool (e.g. art_Illumina as the configuration below demonstrates) to use
are specified in the configuration.

```yaml
# genomes.tsv has path_to_fna/genome_id
genomes_list: "genomes.tsv"

readsim:
  tool: "art"
  binary: "art_illumina"
  read_length: 150
```

## Use case: (Missing `taxonomy`) I don't know genome taxonomies, but I know the genome sequences.

A missing genome taxonomy `taxonomy` file
can be generated from the file of **paths to genome sequences** `genomes_list`
if a taxonomic classification tool
(e.g. Genome Tree Database Toolkit release 207 as the below configuration demonstrates)
is specified in the configuration.

```yaml
classify:
  tool: "gtdbtk"
  release: "207"
  directory: "tmp/genomes.gtdbtk_r207"
  data: "tmp/gtdbtk_r207_v2_data"
```

## Configfile options

`truth`
- Path to a tsv with columns named `sample`, `taxonomy`, `coverage`.
  True taxonomic profile.

`samples`
- Object describing samples, which are collections of paired-end reads,
  containing the following fields:

  `names`
  - List of names of samples.

  `reads1`
  - List of paths to forward reads in fastq format.

  `reads2`
  - List of paths to reverse reads in fastq format.
  
  Optionally also containing:

  `coverages`
  - List of paths to tsv files with two (unnamed) columns
    containing 1. OTU identifiers, and 2. coverages.

`taxonomy`
- Path to a tsv file with two (unnamed) columns 
  containing 1. OTU identifiers,
  and 2. semi-colon separated taxonomy strings.

`genomes_list`
- Object describing lists of source genomes,
  containing the following fields:
  
  `user`
  - Path to a tsv file with two (unnamed) columns
    containing 1. paths to genome sequences in fasta format,
    and 2. OTU identifiers.
  
  `accession`
  - Path to a tsv file with two (unnamed) columns
    containing 1. paths to genome sequences in fasta format,
    and 2. NCBI accession numbers.
  
  `taxon`
  - Path to a tsv file with two (unnamed) columns
    containing 1. paths to genome sequences in fasta format,
    and 2. NBCI taxids or names.
  
  Alternatively, can be a path which is interpreted as an object with a `user` field with the path as value.

`readsim`
- Object describing configuration of tool to use for read simulation.
  Supported tools: 'art'.

  An 'art' configuration object contains the following fields:
  
  `tool`
  - Name of tool: 'art'.

  `read_length`
  - Simulated read length.

  `binary`
  - Name of art executable on PATH or path to executable.

`classify`
- Object describing configuration of tool to use for genome classification.
  Supported tools: 'gtdbtk'.

  A 'gtdbtk' configuration object contains the following fields:

  `tool`
  - Name of tool: 'gtdbtk'

  `release`
  - GTDB release (currently supported: r207, r226)
  
  `directory`
  - directory for intermediate GTDB-TK outputs

  `data`
  - path to download GTDB-TK data
