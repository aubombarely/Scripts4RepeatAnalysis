#!/bin/bash

## Script to retrieve the locations of a 
## repeat from the RepeatMasker.out file

usage() {
       echo ""
       echo "USAGE: GetRepeatLocations -i <repeat_id> -r <repeatmasker_out> -o <outbase> -g <genome_gff> -d <max_distance> -f <genome_fasta>";
       echo ""
       echo "This script runs the following steps:";
       echo "   1- Retrieve the locations for the 'repeat_id' variable from the ";
       echo "      'repeatmasker_out' to produce a .bed file."
       echo "   2- Retrieve the 'max_distance' upstream and downstream genes from ";
       echo "      repeat locations using the 'genome_gff' file";
       echo "   3- Retrieve the 'repeat_id' sequences using the 'genome_fasta' file";
       echo "";
       exit 1; 
}

while getopts "i:r:o:g:d:f:" o; do
    case "${o}" in
        i)
	    repid=${OPTARG}
	    ;;
	r)
	    input=${OPTARG}
	    ;;
	o)
	    outbase=${OPTARG}
	    ;;
	g)
	    genome_gff=${OPTARG}
	    ;;
	d)
	    max_distance=${OPTARG}
	    ;;
	f)
	    genome_fasta=${OPTARG}
	    ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


bedout=$outbase".locations.bed";
if [[ -s $input ]]
   then
       echo "";
       echo "1- Retrieving the repeat $repid locations from the $input file";
       grep -P "$repid\s+" $input | sed -r 's/\s+/\t/g' | cut -f6,7,8 > $bedout;
       echo "    Done. Outfile: $bedout";
       echo "";
       if [[ ! -s $bedout ]]
          then
             echo "No $repid repeatID was found in the file $input. Exiting...";
             echo "";
             exit;
       fi
   else
       echo "ERROR: No -r <repeatmasker_out> file was supplied. Please check instructions. Exiting...";
       echo "";
       exit;
fi

upstream_genes=$outbase"_upstream_geneids.txt";
downstream_genes=$outbase"_downstream_geneids.txt";

echo "";
if [[ -s $genome_gff ]]
   then
   echo "2- Retrieving the Upstream & Downstream Genes using the $genome_gff file";
   re='^[0-9]+$'
   if [[ $max_distance =~ $re ]] ;
      then
          dist_plusone=$(($max_distance+1));
          neg_dist=$((-1*$dist_plusone));
          bedtools closest -a $bedout -b $genome_gff -D b | awk '{ if ($13 < 0 && $13 > '$neg_dist') print $0}' | cut -f12 | cut -d ';' -f1 | sed -r 's/ID=//' > $upstream_genes;
          bedtools closest -a $bedout -b $genome_gff -D b | awk '{ if ($13 > 0 && $13 < '$dist_plusone') print $0}' | cut -f12 | cut -d ';' -f1 | sed -r 's/ID=//' > $downstream_genes;
      else
          echo "ERROR: -d <max_distance> argument is not a numeric value: $max_distance";
          exit;
   fi
   else
       echo "WARNING: No -g <genome_gff> file supplied. Skipping step.";
fi

repeat_fasta=$outbase"_"$repid".fasta";
echo "";

if [[ -s $genome_fasta ]]
   then
   echo "3- Retriving the Repeat sequences from $genome_fasta file";
   bedtools getfasta -fi $genome_fasta -bed $bedout > $repeat_fasta;
   else
      echo "WARNING: No -f <genome_fasta> file supplied. Skipping step.";
fi

echo "";
date;
