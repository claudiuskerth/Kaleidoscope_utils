#!/bin/bash

echo
echo "This is a post-processing script for meta.csv, a file created by Kaleidoscope batch processing."
echo "This script should be run after manual id of recordings."
echo

if [[ $1 == -h* ]]
then
	echo "Usage: postprocessing_meta.sh <KML file> [<species code>]"
	echo
	echo "If run from the output directory of Kaleidoscope batch processing it will:"
	echo -e "\tcheck that files meta.csv and id_notes.csv exist"
	echo -e "\t+ make a backup of meta.csv before postprocessing"
	echo -e "\t+ remove double quotes and carriage returns within meta.csv if they exist"
	echo -e "\t+ add system UID into the column REVIEW USERID of meta.csv"
	echo -e "\t+ join ID NOTES column of id_notes.csv to meta.csv"
	echo -e "\t+ discard some useless columns from meta.csv"
	echo -e "\t+ create a meta.kml from meta.csv allowing for specification of a K species code to create species-specific KML files"
	echo
fi
exit 0

# check that files exist
if [ ! -e meta.csv ]
then
	echo "Cannot find meta.csv."
	exit 1
fi

if [ ! -e id_notes.csv ]
then
	echo "Cannot find id_notes.csv. This files was created by the pre-processing script."
	exit 1
fi

if (( ! $# > 0 )) && (( ! $# < 3 ))
then
	echo "You need to specifiy a kml file from the EMT app."
	echo "Optionally you can specify a species code from Kaleidoscope to create a one-species-only kml file."
	echo "You cannot give more than two command line arguments."
fi


# make backup of manual id work
echo "I am making a backup of your work in meta_after_review.csv before continuing with post-processing meta.csv."
cp meta.csv meta_after_review.csv

# remove double quotes if they exist
if grep "\"" meta.csv; 
	then 
		# if two species codes have been given to a recording, but separated by a comma
		if grep -E '"[^"]+,[^"]+"' meta.csv
		then
			echo "Separating multi-species entries by a semicolon..."
			perl -F/\",\"/  -i -lane'map {tr/,/;/} @F; print join(",", @F)' meta.csv
		fi
		echo "meta.csv contains double quotes. Removing them ..." 
		tr -d '"' < meta.csv > meta_noquotes.csv
		mv meta_noquotes.csv meta.csv
fi

# check if all fields in MANUAL ID column of meta.csv have been filled
cut -d, -f24 meta.csv | grep "^$" > /dev/null
if  [ $? -eq 0 ]
then
	echo "Cannot start post-processing. You have not finished filling the MANUAL ID column in meta.csv."
	exit 1
else
	echo "You seem to have finished manual review of recordings."
fi

# remove carriage returns if they exist
tr -d '\r' < meta.csv > meta_noCR.csv
mv -f meta_noCR.csv meta.csv

# add system UID into column REVIEW USERID
echo "Adding your system user id to the REVIEW USERID column of meta.csv: $USER"
perl -F"," -lane 'BEGIN{chomp($user = `echo \$USER`);}if($.==1){print; for($i=0;$i<@F;$i++){if($F[$i] =~ /^REVIEW USERID$/){$Spalte=$i;}}}else{$F[$Spalte] = $user; print join(",", @F)}' meta.csv > meta_with_USERID.csv
if [ $? -eq 0 ]
then
	mv -f meta_with_USERID.csv meta.csv
else
	echo "Seem to have trouble adding USER ID. Quitting..."
	exit 1
fi

# add date in new column MANUAL ID DATE
echo "Adding new column called MANUAL ID DATE to meta.csv."
perl -F, -ne'BEGIN{chomp($date = `date +%Y-%m-%d`);} chomp; if($. == 1){print; print ",", "MANUAL ID DATE", "\n";}else{print; print ",", $date, "\n";}' meta.csv > meta_with_ID_DATE.csv
if [ $? -eq 0 ]
then
	mv -f meta_with_ID_DATE.csv meta.csv
else
	echo "Seem to have trouble adding an ID DATE column to meta.csv. Quitting ..."
	exit 1
fi

# joining ID Notes column from id_notes.csv to meta.csv after editing id_notes.csv in spreadsheet app.
# The file id_notes.csv needs to have seven columns with IN FILE as the first column
# and ID NOTES as the seventh column
COLNUM=$(head -n 1 id_notes.csv | tr ',' '\n' | wc -l)
if [ $COLNUM -eq 7 ]
then
	echo "Joining notes column from id_notes.csv to meta.csv."
	join -t, -1 3 -2 1  meta.csv <(cut -d, -f1,7 id_notes.csv) > meta_with_id_notes.csv
	if [ $? -eq 0 ]
	then
		mv -f meta_with_id_notes.csv meta.csv
	else
		echo "Seem to have trouble joining id notes to meta. Quitting..."
		exit 1
	fi
else
	echo "Cannot join ID NOTES column. File id_notes.csv does not have seven columns."
	exit 1
fi

# select columns from meta.csv
echo "Selecting columns from meta.csv. Some can be dropped, really."
cp meta.csv atem.vsc
cut -d, -f1,5-6,11-13,15,17-18,24,26,28,30- meta.csv > atem.vsc
mv atem.vsc meta.csv

# create KML file from meta.csv allowing to specify a species
if [ "$1" == "" ]
then
	echo "Cannot create meta.kml file from meta.csv, since you haven't specified a EMT-app KML to take the style from."
	exit 1
else
	if [ "$2" == "" ]
	then
		style2kml.pl --meta meta.csv --EMT-kml $1 > meta.kml
		echo "Creating meta.kml file from meta.csv."
	else
		style2kml.pl --meta meta.csv --EMT-kml $1 --species $2 > meta.kml
		echo "Creating meta.kml file from meta.csv but only for species $2."
	fi
fi
