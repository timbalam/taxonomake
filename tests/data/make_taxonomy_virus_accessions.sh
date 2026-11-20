datasets summary virus genome accession NC_000935.1 NC_001420.2 --as-json-lines |
    dataformat tsv virus-genome --fields accession,virus-tax-id --elide-header |
    taxonkit reformat2 -I 2 -f "Root;d__{domain|acellular root|superkingdom};p__{phylum};c__{class};o__{order};f__{family};g__{genus};s__{species}" |
    cut -f1,3- > taxonomy_virus_accessions.tsv