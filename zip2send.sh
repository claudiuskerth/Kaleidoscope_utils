#!/bin/bash

echo "This script should be run after post-processing from within the output directory."
echo
echo "It will create a zip archive with all non-Noise audio files, meta.csv and meta*kml files."
echo

# create a file list to include in the zip archive
cut -d, -f1 meta.csv | tail -n +2 | tr -d '"' | sed -E 's/(.*)/*\1/' > include.lst

# create README file
echo "
If you have decompressed the zip archive to its own directory (e.g. MyColleaguesRecordings), like:

	unzip MyColleaguesRecordings.zip -d MyColleaguesRecordings

then you can open meta.csv with Kaleidoscope after setting the input directory in Kaleidsocope's Control Panel to MyColleaguesRecordings (that means the whole path to that directory). That way Kaleidoscope is able to find the audio recordings listed in meta.csv. 
" > README

# create a zip archive with the selected files
if [[ ! $# == 1 ]]
then
	echo "Usage:  zip2send.sh <name-of-zip-archive>"
	echo
	echo "You need to give the name of the zip archive (nothing more)."
	exit 1
else
	zip -r $1 . -i@include.lst -i meta.csv meta_ManualID.kml meta_NR.kml README
fi

rm -f README
