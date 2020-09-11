#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: style2kml.pl
#
#        USAGE: ./style2kml.pl --EMT-kml EMT-session-KML --meta meta.csv --species [e.g. HYPSAV]
#
#  DESCRIPTION: Takes a file containing the style definition from an EMT session KML
#  				and a meta.csv file and turns the meta.csv into a KML file with the
#  				styles taken from the EMT session KML.
#
#      OPTIONS: ---
# REQUIREMENTS: ogr2ogr (GDAL)
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Claudius Kerth (CEK), claudiuskerth[at]gmail.com
# ORGANIZATION: Sheffield University
#      VERSION: 1.0
#      CREATED: 14/08/2020 16:49:22
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $usage = "usage: 

$0 --meta <your meta.csv> --EMT_kml <kml from EMT app> [--species <species abbreviation>]

--meta your meta.csv file name (and path)
--EMT_kml any Session*kml file name from EMT app 
[--species species abbreviation as used by Kaleidoscope, e.g. HYPSAV]

prints result to STDOUT
\n";

system("which ogr2ogr > /dev/null") == 0 or die "You need to have the utility ogr2ogr installed and in your PATH.
https://gdal.org/download.html\n";

my ($meta, $EMT_kml, $species);

sub parse_command_line {
	while(@ARGV){
		$_ = shift @ARGV;
		if(/^-{1,2}meta$/){$meta = shift @ARGV;}
		elsif(/^-{1,2}species$/){$species = shift @ARGV;}
		elsif(/^--EMT-kml$/){$EMT_kml = shift @ARGV;}
		elsif(/^-{1,2}h(elp)?$/){die $usage;}
	}
}


parse_command_line();
die $usage unless (defined($meta) && ($meta ne "") && defined($EMT_kml) && ($EMT_kml ne ""));

# extracts the style definition from a session kml produced by EMT app
# we want to reuse the style in our new KML file
# sub get_style {
# 	my $style_fh;
# 	open($style_fh, "<", $EMT_kml) or die $!;
# 	local $/ = undef; # set input record separator to undef -> slurp mode
# 	local $_ = <$style_fh>;
# 	# print;
# 	# needs /s to include newline with dot; 
# 	# needs /m to allow ^ and $ to match at newline not just at beginning 
# 	# and end of the multi-line string
# 	/^(\s+<Style.*<\/Style>$)/sgm; 
# 	return($1);
# }

# extracts the style definition from a session kml produced by EMT app
# we want to reuse the style in our new KML file
sub get_style{
 	my $style_fh;
 	open($style_fh, "<", $EMT_kml) or die $!;
	while(<$style_fh>){
		print if /<Style/ .. /<\/Style>/;
	}
}


# printf('ogr1ogr \
# -f KML meta_raw.kml \ 
# %s \
# -a_srs \'EPSG:4325\' \
# -oo X_POSSIBLE_NAMES=LON* -oo Y_POSSIBLE_NAMES=LAT* \
# -oo KEEP_GEOM_COLUMNS=NO \
# -where  "\"MANUAL ID\" LIKE \'%%%s%%\'" \
# -dsco NameField="IN FILE"', $meta, $species);
# print get_style();
# exit;

# generate KML from the meta.csv file after manual id
my $cmd;
if(defined $species and $species ne ""){
	$cmd = sprintf("ogr2ogr -f KML meta_raw.kml %s -a_srs \'EPSG:4326\' -oo X_POSSIBLE_NAMES=LON\* -oo Y_POSSIBLE_NAMES=LAT\* -oo KEEP_GEOM_COLUMNS=NO -where  \"\\\"MANUAL ID\\\" LIKE \'%%%s%%\'\" ", $meta, $species);
}else{
	$cmd = sprintf("ogr2ogr -f KML meta_raw.kml %s -a_srs \'EPSG:4326\' -oo X_POSSIBLE_NAMES=LON\* -oo Y_POSSIBLE_NAMES=LAT\* -oo KEEP_GEOM_COLUMNS=NO", $meta);
}
system($cmd) == 0 or die $!;


# open the KML to which the style should be added
open (my $metaKML, "meta_raw.kml") or die $!;
my ($manual_id, $date, $time, @manual_IDs);

# add required style info
# use MANUAL ID for marker style (the Session KML uses AUTO ID)
while(<$metaKML>){
	print;
	# add the style definition after the Document XML tag
	if(/<Document.*>/){
		print get_style();
		#		print "\n";
	}
	# add marker style XML tag to each Placemark
	elsif(/"MANUAL ID"/ and /SimpleData/){
		($manual_id) = $_ =~ />(.*)</;
		#	}elsif(/"DATE">/ and /SimpleData/){
		#		($date) = $_ =~ />(.*)</;
		#	}elsif(/"TIME">/ and /SimpleData/){
		#		($time) = $_ =~ />(.*)</;
	}elsif(/<\/ExtendedData>/){
		@manual_IDs = split(/;/, $manual_id);
		# MarkerStyle for first species
		print "\t<styleUrl>#MarkerStyle", $manual_IDs[0], "</styleUrl>\n"; 
		# put manual ids in name tag
		print "\t<name>", join(', ', @manual_IDs), "</name>\n"; 
	}
}

# clean up
system("rm -f meta_raw.kml") == 0 or die $?;
