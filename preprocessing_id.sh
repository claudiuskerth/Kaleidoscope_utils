#!/bin/bash

echo
echo "This is a pre-processing script for id.csv, a file created by Kaleidoscope batch processing."
echo

if [ $# != 0 ]
then
	echo "This script takes no command line arguments."
	if [[ $1 == -h* ]]
	then
		echo "If run from the output directory of Kaleidoscope batch processing it will:"
		echo -e "\t+ make a backup of the original id.csv"
		echo -e "\t+ remove double quotes within id.csv if they exist"
		echo -e "\t+ make the MANUAL ID column blank within id.csv"
		echo -e "\t+ sort id.csv according to date and time"
		echo -e "\t+ add a record number column to id.csv"
		echo -e "\t+ insert the label noise into the column AUTO ID for recordings that have been moved to the subfolder NOISE"
		echo -e "\t+ create a file called id_notes.csv from id.csv for note taking in a spreadsheet app"
		echo
	fi
	exit 0
fi

# check for signs that preprocessing has already been run 
# to avoid deletion of manual id results and confusion
if [ -e id_orig.csv -o -e id_notes.csv ]
then
	echo
	echo !!!
	echo "Have you run this script already? Check that id.csv is the original version created by Kaleidoscope batch processing."
	echo "If you are sure you are at the beginning of manual review, remove id_orig.csv and id_notes.csv. Then run this script again."
	echo !!!
	echo
	exit 1
fi


# make a copy of the original id.csv
if [ -e id.csv ]
then
	echo "A copy of the original id.csv file will be stored in id_orig.csv."
	cp id.csv id_orig.csv
else
	echo "Cannot find id.csv. Run this script from inside the output directory of Kaleidoscope batch processing."
	exit 1
fi

# remove double quotes if they exist
if grep "\"" id_orig.csv > /dev/null; 
	then 
		echo "id.csv contains double quotes. Removing them ..." 
		tr -d '"' < id_orig.csv > id.csv
fi

# remove carriage returns if they exist
tr -d '\r' < id.csv > id_noCR.csv
mv -f id_noCR.csv id.csv

# remove asterisks if they exist
# the column names sometimes get asterisks from Kaleidoscope
tr -d '*' < id.csv > id_noAst.csv
mv -f id_noAst.csv id.csv

# make MANUAL ID column blank
echo "making manual id column blank ..."
perl -i -lne '@F = split(",", $_, -1); if($.==1){print; for($i=0;$i<@F;$i++){if($F[$i] =~ /^MANUAL ID$/){$Spalte=$i}}}else{$F[$Spalte] = ""; print join(",", @F)}' id.csv

# sort id.csv by date, then by time
echo "sorting id.csv by date and time ..."
mv id.csv atem.vsc
cat <(head -1 atem.vsc) <(tail +2 atem.vsc | sort -t, -k10 -k11) > id.csv
rm -f atem.vsc

# add line number column
echo "adding a record number column ..."
mv id.csv atem.vsc
perl -lne 'chomp; if($.==1){print $_, ",NR";}else{print $_, ",", $.-1;}' atem.vsc > id.csv
rm -f atem.vsc

# check if a directory called NOISE exists
# if yes, then add noise label to AUTO ID column
if [ -e NOISE ] 
	then 
		echo "Inserting label \"Noise\" in AUTO ID column ..."
		perl -F, -i -lane 'if($.==1){print}else{($file = $F[2]) =~ s/^(.*)\.(.*)/$1_000.$2/; $file = "NOISE/" . $file; if(-e $file){$F[17] = "Noise"}; print join(",", @F)}' id.csv
	else
		echo "No directory called NOISE found. Run Kaleidoscope batch process with appropriate settings."
		echo "Cannot insert noise label in AUTO ID column."
fi

# create id_notes.csv for note taking in spreadsheet app
echo "Creating file id_notes.csv for note taking ..."
INFILECOLNUM=$(head -n 1 id.csv | tr ',' '\n' | nl | grep "IN FILE" | cut -f1)
cut -d, -f$INFILECOLNUM,5-6,18,24,30 id.csv > id_notes.csv

# # creating id_NR.kml
# echo "Creating id_NR.kml ..."
# style2kml.pl --meta id.csv --NR > id_NR.kml
