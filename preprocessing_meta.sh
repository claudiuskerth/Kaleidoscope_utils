#!/bin/bash

echo
echo "This is a pre-processing script for meta.csv, a file created by Kaleidoscope batch processing."
echo

if [ $# != 0 ]
then
	echo "This script takes no command line arguments."
	if [[ $1 == -h* ]]
	then
		echo "If run from the output directory of Kaleidoscope batch processing it will:"
		echo -e "\t+ make a backup of the original meta.csv"
		echo -e "\t+ remove double quotes within meta.csv if they exist"
		echo -e "\t+ make the MANUAL ID column blank within meta.csv"
		echo -e "\t+ sort meta.csv according to date and time"
		echo -e "\t+ add a record number column to meta.csv"
		echo -e "\t+ insert the label noise into the column AUTO ID for recordings that have been moved to the subfolder NOISE"
		echo -e "\t+ create a file called id_notes.csv from meta.csv for note taking in a spreadsheet app"
		echo
	fi
	exit 0
fi

# check for signs that preprocessing has already been run 
# to avoid deletion of manual id results and confusion
if [ -e meta_orig.csv -o -e id_notes.csv ]
then
	echo
	echo !!!
	echo "Have you run this script already? Check that meta.csv is the original version created by Kaleidoscope batch processing."
	echo "If you are sure you are at the beginning of manual review, remove meta_orig.csv and id_notes.csv. Then run this script again."
	echo !!!
	echo
	exit 1
fi


# make a copy of the original meta.csv
if [ -e meta.csv ]
then
	echo "A copy of the original meta.csv file will be stored in meta_orig.csv."
	cp meta.csv meta_orig.csv
else
	echo "Cannot find meta.csv. Run this script from inside the output directory of Kaleidoscope batch processing."
	exit 1
fi

# remove double quotes if they exist
if grep "\"" meta_orig.csv; 
	then 
		echo "meta.csv contains double quotes. Removing them ..." 
		tr -d '"' < meta_orig.csv > meta.csv
fi

# remove carriage returns if they exist
tr -d '\r' < meta.csv > meta_noCR.csv
mv -f meta_noCR.csv meta.csv

# make MANUAL ID column blank
echo "making manual id column blank ..."
perl -F"," -i -lane 'if($.==1){print; for($i=0;$i<@F;$i++){if($F[$i] =~ /^MANUAL ID$/){$Spalte=$i}}}else{$F[$Spalte] = ""; print join(",", @F)}' meta.csv

# sort meta.csv by date, then by time
echo "sorting meta.csv by date and time ..."
mv meta.csv atem.vsc
cat <(head -1 atem.vsc) <(tail +2 atem.vsc | sort -t, -k5 -k6) > meta.csv
rm -f atem.vsc

# add line number column
echo "adding a record number column ..."
mv meta.csv atem.vsc
perl -F"," -ne 'chomp; if($.==1){print $_, ",NR", "\n";}else{print $_, ",", $.-1, "\n";}' atem.vsc > meta.csv
rm -f atem.vsc

# check if a directory called NOISE exists
# if yes, then add noise label to AUTO ID column
if [ -e NOISE ] 
	then 
		echo "Inserting label \"Noise\" in AUTO ID column ..."
		perl -F, -i -lane 'if($.==1){print}else{($file = $F[2]) =~ s/^(.*)\.(.*)/$1_000.$2/; $file = "NOISE/" . $file; if(-e $file){$F[17] = "Noise"}; print join(",", @F)}' meta.csv
	else
		echo "No directory called NOISE found. Run Kaleidoscope batch process with appropriate settings."
		echo "Cannot insert noise label in AUTO ID column."
fi

# create id_notes.csv for note taking in spreadsheet app
echo "creating file id_notes.csv for note taking ..."
cut -d, -f3,5-6,18,24,30 meta.csv > id_notes.csv
