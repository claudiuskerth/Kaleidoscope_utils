#!/bin/bash

echo
echo "This is a post-processing script for meta.csv, a file created by Kaleidoscope batch processing."
echo "This script should be run after manual id of recordings from within the output directory."
echo

if [[ $1 == -h* ]]
then
	# echo "Usage: postprocessing_meta.sh <KML file> [<species code>]"
	echo "Usage: postprocessing_meta.sh [<species code>]"
	echo
	echo "If run from the output directory of Kaleidoscope batch processing it will:"
	echo -e "\t+ check that files meta.csv and id_notes.csv exist"
	echo -e "\t+ make a backup of meta.csv before postprocessing"
	echo -e "\t+ remove double quotes and carriage returns within meta.csv if they exist, separating multi-species entries by a semicolon"
	echo -e "\t+ add system UID into the column REVIEW USERID of meta.csv"
	echo -e "\t+ join ID NOTES column of id_notes.csv to meta.csv after replacing commas in notes with semicolons"
	echo -e "\t+ discard some useless columns from meta.csv"
	echo -e "\t+ create a meta.kml from meta.csv allowing for specification of a K species code to create species-specific KML files"
	echo
	exit 0
fi

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

#if (( ! $# > 0 )) && (( ! $# < 3 ))
if [[ ! $# < 2 ]]
then
	# echo "Usage: postprocessing_meta.sh <KML file> [<species code>]"
	echo "Usage: postprocessing_meta.sh [<species code>]"
	echo
#	echo "You need to specifiy a kml file from the EMT app."
	echo "Optionally you can specify a species code from Kaleidoscope to create a one-species-only kml file."
	#echo "You cannot give more than two command line arguments."
	echo "You cannot give more than one command line argument."
	exit 1
fi

if [ -e meta_after_review.csv ]
then
	echo "You seem to have run postprocessing already. Restoring original meta.csv."
	cp meta_after_review.csv meta.csv
fi


# make backup of manual id work
echo "I am making a backup of your work in meta_after_review.csv before continuing with post-processing meta.csv."
echo "Do note [re]move meta_after_review.csv!"
cp meta.csv meta_after_review.csv

# remove double quotes if they exist
if grep "\"" meta.csv > /dev/null 
	then 
		# if two or more species codes have been given to a recording, but separated by a comma
		if grep -E '"[^"]+,[^"]+"' meta.csv > /dev/null
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

# remove asterisks if they exist
# the column names sometimes get asterisks from Kaleidoscope
tr -d '*' < meta.csv > meta_noAst.csv
mv -f meta_noAst.csv meta.csv

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
	# if notes in ID NOTES column contain commas
	if grep -E '"[^"]+(,[^"]+)+"' id_notes.csv > /dev/null
	then
		echo "Replacing commas with semicolons in ID NOTES column..."
		perl -i -pe'next if not /"$/; ($pre_note, $note) = $_ =~ /(.*,)(".*"$)/; $note =~ tr/,/;/; $_ = $pre_note . $note . "\n";' id_notes.csv
	fi
	# remove double quotes
	if grep "\"" id_notes.csv > /dev/null
	then
		echo "id_notes.csv contains double quotes. Removing them ..." 
		tr -d '"' < id_notes.csv > id_notes_withoutQuotes.csv
		mv id_notes_withoutQuotes.csv id_notes.csv
	fi
	NRCOLNUM=$(head -n 1 meta.csv | tr ',' '\n' | nl | grep "NR" | cut -f1)
	INFILECOLNUM=$(head -n 1 meta.csv | tr ',' '\n' | nl | grep "IN FILE" | cut -f1)
	join -t, -1 $INFILECOLNUM -2 1 <(sort -t, -nk $NRCOLNUM meta.csv) <(sort -t, -nk 6,6 id_notes.csv | cut -d, -f1,7) > meta_with_id_notes.csv
#	# get header line line from bottom to top (after sorting)
#	NUMLINES=$(wc -l meta.csv | awk '{print $1-1}')
#	tail -1 meta_with_id_notes.csv | tee header.csv | cat - <(head -n $NUMLINES meta_with_id_notes.csv) > meta_with_id_notes_headerTop.csv
	if [ $? -eq 0 ]
	then
		# echo $NUMLINES
		mv -f meta_with_id_notes.csv meta.csv
		rm -f header.csv
		# mv -f meta_with_id_notes_headerTop.csv meta.csv
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

# remove noise recordings
echo "Removing lines for noise recordings from meta.csv."
perl -F, -i'.withNoise' -lane'if($.==1){print; for($i=0;$i<@F;$i++){if($F[$i] =~ /^MANUAL ID$/){$palte=$i}}}else{print if not $F[$palte] =~ /noise/i}' meta.csv

# create meta_withINDIR
echo "Creating  meta_withINDIR.csv  : a version of meta.csv that contains the path to the audio files."
echo "It is therefore suitable for upload to a database."
mv NOISE/* .
rmdir NOISE
rename 's/_000//' *wav
META_NR=$( echo $(( $(wc -l meta.csv | awk '{print $1}') -1 )) )
paste -d, <(echo "INDIR"; for i in $(seq $META_NR); do pwd; done) meta.csv > meta_withINDIR.csv

# create KML file from meta.csv allowing to specify a species
if [ "$1" == "" ]
then
	# style2kml.pl --meta meta.csv --EMT-kml $1 > meta.kml
	style2kml.pl --meta meta.csv > meta_ManualID.kml
	echo "Creating meta_ManualID.kml file from meta.csv."
else
	style2kml.pl --meta meta.csv --species $1 > meta_$1.kml
	printf "Creating meta_%s.kml file from meta.csv for species %s only.\n" $1 $1
#	echo "Creating meta_$1.kml file from meta.csv but only for species $1."
fi
