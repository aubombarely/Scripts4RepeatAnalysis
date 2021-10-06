# Scripts4RepeatAnalysis
This is a collection of simple scripts to retrieve repetitive elements.

## GetRepeatLocations.sh

<p>This Bash script extracts all the repeats from the repeatmasker.out file
specified in the -i <repeat_id> variable producing a .bed file. Then, using
the max_distance and the gff file will extract all the genes close to the
repeat_id location. Finally it will get the sequenced in FASTA format.</p>

<strong>USAGE: GetRepeatLocations -i <repeat_id> -r <repeatmasker_out> -o <outbase> -g <genome_gff> -d <max_distance> -f <genome_fasta></strong>

DESCRIPTION: 

This script runs the following steps:
   1- Retrieve the locations for the 'repeat_id' variable from the 
      'repeatmasker_out' to produce a .bed file.
   2- Retrieve the 'max_distance' upstream and downstream genes from 
      repeat locations using the 'genome_gff' file
   3- Retrieve the 'repeat_id' sequences using the 'genome_fasta' file
