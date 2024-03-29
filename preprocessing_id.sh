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
		echo -e "\t+ add geographic coordinates from meta.csv to id.csv (and Timestamp and Temperature in case of Batlogger data)"
		echo -e "\t+ create a KML file with the locations of all recordings to use for manual review of recordings"
		echo
	fi
	exit 0
fi


# ask the user for important information
echo "Is the data comming from a Batlogger or from a Wildlife Acoustics device (EMT oder SM4BAT)? Type either Batlogger, EMT or SM4BAT followed by [ENTER]:"
read datasource
while [ $datasource != 'Batlogger' -a $datasource != 'EMT' -a $datasource != 'SM4BAT' ]
do
		echo "You've typed: $datasource. Check your spelling and try again:!"
		read datasource
done
if [ $datasource == 'Batlogger' ]
then
		echo 'Your data is coming from a Batlogger. Is that rigth? Type Y to continue or N to exit now:'
		read input
		while [[ $input != [YN] ]]
		do
				echo "Type Y or N:"
				read input
		done
		if [ $input == 'Y' ]
		then
				echo "Going to treat your data as Batlogger data..."
				echo "Have you run xml2csv.py on the BL... folder(s) of your audio data set yet? Type Y or N:"
				read input
				while [[ $input != [YN] ]]
				do
						echo "Type Y or N:"
						read input
				done
				if [ $input == 'Y' ]
				then
						echo "Good! Where can I find the output CSV file from this xml2csv.py run containing the meta data?"
						echo "Give me a relative or absolute path including file name:"
						read metadata
						while [ ! -f $metadata ]
						do
								echo "Sorry, I could not find this file. Check the path and file name, then try again."
								echo "Or type Ctrl + C to exit and come back later."
								read metadata;
						done
						echo "Ok, going to use the meta data in $metadata."
				elif [ $input == 'N' ]
				then
						echo "Well, you need to do that first before running this script. See you later :-)"
						exit 1;
				fi
		elif [ $input == 'N' ]
		then
				echo "Ok, exiting now. No worries, just try again :-)"
				exit 1;
		fi
elif [ $datasource == 'EMT' -o  $datasource == 'SM4BAT' ]
then
		echo "Your data is coming from a Wildlife Acoustics device. Is that rigth? Type Y to continue or N to exit now:"
		read input
		while [[ $input != [YN] ]]
		do
				echo "Type Y or N:"
				read input
		done
		if [ $input == 'Y' ]
		then
				echo "Going to treat your data as Wildlife Acoustic data..."
		elif [ $input == 'N' ]
		then
				echo "Ok, exiting now. No worries, just try again :-)"
				exit 1;
		fi
else
		exit 1;
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

if [ $datasource == 'EMT' -o  $datasource == 'SM4BAT' ]
then
		# sort id.csv by date, then by time
		echo "sorting id.csv by date and time ..."
		mv id.csv atem.vsc
		cat <(head -1 atem.vsc) <(tail +2 atem.vsc | sort -t, -k10 -k11) > id.csv
		rm -f atem.vsc
else
		# sort id.csv by filename
		echo "sorting id.csv by file name ..."
		INFILECOLNUM=$(head -n 1 id.csv | tr ',' '\n' | nl | grep "IN FILE" | cut -f1)
		mv id.csv atem.vsc
		cat <(head -1 atem.vsc) <(tail +2 atem.vsc | sort -t, -k $INFILECOLNUM ) > id.csv
		rm -f atem.vsc
fi

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
cut -d, -f$INFILECOLNUM,10,11,16,37,45 id.csv > id_notes.csv

# add geographic coordinates from meta.csv
## sort  meta.csv by file name before joining
cp $metadata vsc.atem
cat <(head -n 1 vsc.atem) <(tail -n +2 vsc.atem | sort -t, -k2,2) > $metadata
rm -f vsc.atem

if [ $datasource == 'EMT' -o  $datasource == 'SM4BAT' ]
then
		echo "adding geographic coordinate columns from Kaleidoscope's meta.csv..."
		## join geographic coordinate columns to id.csv
		join -t"," -1 $INFILECOLNUM -2 1 id.csv <(cut -d, -f3,11,12 meta.csv) > id_with_LatLon.csv
		## sort by NR column again
		cat <(head -n 1 id_with_LatLon.csv) <(tail -n +2 id_with_LatLon.csv | sort -t, -nk45,45) > id.csv
		rm -f id_with_LatLon.csv
else
		## add meta data, including coordinates, from output file of xml2csv.py
		echo "adding geographic coordinate columns from xml2csv.py's meta.csv..."
		## join geographic coordinate columns to id.csv
		mv id.csv vsc.di
		join -t"," -1 $INFILECOLNUM -2 1 vsc.di <(cut -d, -f2-4,6-7 $metadata | sed 's/wavFileName/IN FILE/') > id.csv
		rm -f vsc.di
fi

# creating id_NR.kml
echo "Creating id_NR.kml ..."
style2kml.pl --meta id.csv --NR > id_NR.kml
