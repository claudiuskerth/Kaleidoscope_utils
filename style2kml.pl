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

$0 --meta <your meta.csv> [--NR] [--species <species abbreviation>]

--meta      your meta.csv file name (and path)
--NR        optional, if set, puts the number of record into the name tag instead of the MANUAL IDs
--species   optional, takes species abbreviation as used by Kaleidoscope, e.g. HYPSAV

prints result to STDOUT
\n";

# my $usage = "usage: 
# 
# $0 --meta <your meta.csv> --EMT_kml <kml from EMT app> [--NR] [--species <species abbreviation>]
# 
# --meta      your meta.csv file name (and path)
# --EMT-kml   any Session*kml file name from EMT app 
# --NR        optional, if set, puts the number of record into the name tag instead of the MANUAL IDs
# --species   optional, takes species abbreviation as used by Kaleidoscope, e.g. HYPSAV
# 
# prints result to STDOUT
# \n";

system("which ogr2ogr > /dev/null") == 0 or die "You need to have the utility ogr2ogr installed and in your PATH.
https://gdal.org/download.html\n";

my ($meta, $species);
# my ($meta, $EMT_kml, $species);
my $NR = 0;

sub parse_command_line {
	while(@ARGV){
		$_ = shift @ARGV;
		if(/^-{1,2}meta$/){$meta = shift @ARGV;}
		elsif(/^-{1,2}species$/){$species = shift @ARGV;}
		#		elsif(/^--EMT-kml$/){$EMT_kml = shift @ARGV;}
		elsif(/^-{1,2}NR$/){$NR = 1;}
		elsif(/^-{1,2}h(elp)?$/){die $usage;}
	}
}


parse_command_line();
die $usage unless (defined($meta) && ($meta ne ""));
# die $usage unless (defined($meta) && ($meta ne "") && defined($EMT_kml) && ($EMT_kml ne ""));

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

# # extracts the style definition from a session kml produced by EMT app
# # we want to reuse the style in our new KML file
# sub get_style{
#  	my $style_fh;
#  	open($style_fh, "<", $EMT_kml) or die $!;
# 	while(<$style_fh>){
# 		print if /<Style/ .. /<\/Style>/;
# 	}
# }

# hardcode the style instead of extracting it from a session KML file
my $style = '<Style id="SessionStyle">
         <LineStyle>
            <color>#FF8565CF</color>
            <width>4.0</width>
         </LineStyle>
      </Style>
      <Style id="MarkerStyleANTPAL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_ANTPAL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleCHOMEX">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_CHOMEX.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleCORTOW">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_CORTOW.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTFUS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTFUS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEUDMAC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EUDMAC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEUMFLO">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EUMFLO.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEUMPER">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EUMPER.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEUMUND">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EUMUND.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleIDIPHY">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_IDIPHY.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASNOC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASNOC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASBLO">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASBLO.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASBOR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASBOR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASCIN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASCIN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASEGA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASEGA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASINT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASINT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASSEM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASSEM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASXAN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASXAN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLEPNIV">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LEPNIV.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLEPYER">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LEPYER.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMACCAL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MACCAL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMOLMOL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MOLMOL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMORMEG">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MORMEG.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOAUR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOAUR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOAUS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOAUS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOCAL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOCAL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOCIL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOCIL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOEVO">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOEVO.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOGRI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOGRI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOKEE">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOKEE.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOLEI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOLEI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOLUC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOLUC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOOCC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOOCC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOSEP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOSEP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOSOD">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOSOD.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOTHY">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOTHY.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOVEL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOVEL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOVOL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOVOL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOYUM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOYUM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCHUM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCHUM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCFEM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCFEM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCMAC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCMAC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePARHES">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PARHES.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePERSUB">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PERSUB.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleTADBRA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_TADBRA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleBARBAR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_BARBAR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTISA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTISA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTNIL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTNIL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTSER">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTSER.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleHYPSAV">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_HYPSAV.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMINSCH">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MINSCH.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOALC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOALC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOBEC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOBEC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOBRA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOBRA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOCAP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOCAP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYODAS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYODAS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYODAU">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYODAU.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOEMA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOEMA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOESC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOESC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOMYO">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOMYO.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOMYS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOMYS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYONAT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYONAT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCLAS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCLAS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCLEI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCLEI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCNOC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCNOC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePIPKUH">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PIPKUH.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePIPNAT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PIPNAT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePIPPIP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PIPPIP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePIPPYG">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PIPPYG.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePLEAUR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PLEAUR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePLEAUS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PLEAUS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIEUR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIEUR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIFER">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIFER.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIHIP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIHIP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleTADTEN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_TADTEN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleVESMUR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_VESMUR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleBALIO">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_BALIO.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleBALPLI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_BALPLI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleBAUDUB">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_BAUDUB.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleCENCEN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_CENCEN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleCENMAX">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_CENMAX.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleCYNMEX">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_CYNMEX.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleDICALB">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_DICALB.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTBRA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTBRA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTFUR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTFUR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEUMGLA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EUMGLA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLASINS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LASINS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMOLTEM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MOLTEM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMOLRUF">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MOLRUF.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMOLSIN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MOLSIN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMORBLA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MORBLA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOELE">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOELE.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOKEA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOKEA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYONIG">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYONIG.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYORIP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYORIP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNOCLEP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NOCLEP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNYCLAT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NYCLAT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePERKAP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PERKAP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePERMAC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PERMAC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePROCEN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PROCEN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePTEDAV">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PTEDAV.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePTEGYM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PTEGYM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePTEMAC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PTEMAC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePTEPAR">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PTEPAR.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePTEPER">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PTEPER.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePTEQUA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PTEQUA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHOAEN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHOAEN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHOIO">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHOIO.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHYNAS">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHYNAS.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleSACBIL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_SACBIL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleSACLEP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_SACLEP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleCHAPUM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_CHAPUM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleEPTHOT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_EPTHOT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleLAEBOT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_LAEBOT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMINNAT">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MINNAT.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleMYOBOC">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_MYOBOC.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNEOCAP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NEOCAP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStylePIPHES">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_PIPHES.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIBLA">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIBLA.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHICAP">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHICAP.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHICLI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHICLI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIDEN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIDEN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIFUM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIFUM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHIHIL">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHIHIL.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHISIM">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHISIM.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHISMI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHISMI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleRHISWI">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_RHISWI.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleSAUPET">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_SAUPET.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleSCONIG">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_SCONIG.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleSCODIN">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_SCODIN.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleTADAEG">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_TADAEG.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyleNo_ID">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker_NoID.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
      <Style id="MarkerStyle">
         <IconStyle>
            <hotSpot x="0.5" xunits="fraction" y="0.0" yunits="fraction"/>
            <Icon>
               <href>http://www.wildlifeacoustics.com/echo-meter-touch/gps/marker.png</href>
            </Icon>
         </IconStyle>
         <LabelStyle>
            <scale>0.0</scale>
         </LabelStyle>
      </Style>
';


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
my ($manual_id, $date, $time, @manual_IDs, $number_record);

# add required style info
# use MANUAL ID for marker style (the Session KML uses AUTO ID)
while(<$metaKML>){
	print;
	# add the style definition after the Document XML tag
	if(/<Document.*>/){
		# print get_style();
		print $style;
		#		print "\n";
	}
	# add marker style XML tag to each Placemark
	elsif(/"MANUAL ID"/ and /SimpleData/){
		($manual_id) = $_ =~ />(.*)</;
		#	}elsif(/"DATE">/ and /SimpleData/){
		#		($date) = $_ =~ />(.*)</;
		#	}elsif(/"TIME">/ and /SimpleData/){
		#		($time) = $_ =~ />(.*)</;
	}
	elsif(/SimpleData/ and /"NR"/){
		($number_record) = $_ =~ />(.*)</;
	}
	elsif(/<\/ExtendedData>/){
		if($NR){
			# put number of record into name tag
			print "\t<name>", $number_record, "</name>\n"; 
		}else{
			@manual_IDs = split(/;/, $manual_id);
			# MarkerStyle for first species
			print "\t<styleUrl>#MarkerStyle", $manual_IDs[0], "</styleUrl>\n"; 
			# put manual ids in name tag
			print "\t<name>", join(', ', @manual_IDs), "</name>\n"; 
		}
	}
}

# clean up
system("rm -f meta_raw.kml") == 0 or die $?;
