#!/usr/bin/env python

import glob
import re
import xml.etree.ElementTree as ET
import os
import argparse

# argparse
parser = argparse.ArgumentParser(
        description="collect meta data within XML files of Batlogger and output in one CSV file", epilog="Example: ./xml2csv.py . meta.csv"
        )
parser.add_argument("INPATH", help="path to directory containing Batlogger data (in 'BL...' subdirectories), if current directory use a literal dot '.'")
parser.add_argument("CSV", help="path (optional) with file name of CSV file to create, e.g. 'metadata/meta.csv'")
args = parser.parse_args()

inpath = args.INPATH
outCSV = args.CSV

# check whether inpath can be found
if not os.path.exists(inpath): raise OSError('Could not find input path: ' + inpath)

# check whether output file exists and if so refuse to overwrite
if os.path.exists(outCSV): raise OSError('File ' + outCSV + ' already exists!')

# def function
def xml2csv(INPATH, OUTCSV):
    '''
    docstring
    '''
    p = re.compile('.*/')

    # create iterator over XML files with iglob
    xml_it = glob.iglob(inpath + '/BL*/*xml', recursive=True)

    with open(outCSV, 'w') as outfile:
        print('Folder', 'wavFileName', 'Timestamp', 'Temperature', 'Duration', 'Latitude', 'Longitude', sep=',', file=outfile)
        for xml in xml_it:
            # get file name
            filename = os.path.basename(xml)
            # change 'xml' to 'wav' in file name
            wav = filename.replace('xml', 'wav')
            # get folder name
            dirname = os.path.dirname(xml)
            # remove rest of path
            folder = p.sub('', dirname)

            # read in with ET.parse()
            tree = ET.parse(xml)
            root = tree.getroot()

            # store DateTime, Temp and Position
            # re-initialize
            timestamp, temperature, duration, latitude, longitude  = ('', '', '', '', '')

            try:
                timestamp = root.find('DateTime').text
            except AttributeError:
                print('no timestamp found in: ', xml)
            try:
                temperature = root.find('Temperature').text
            except AttributeError:
                print('no temperature found in: ', xml)
            try:
                duration = root.find('Duration').text
            except AttributeError:
                print('no duration found in: ', xml)
            try:
                latitude, longitude = root.find('GPS').find('Position').text.split(' ')
            except AttributeError:
                print('no GPS position found in: ', xml)

            # print out values in CSV format
            print(folder, wav, timestamp, temperature, duration, latitude, longitude, sep=',', file=outfile)

    return

xml2csv(inpath, outCSV)
