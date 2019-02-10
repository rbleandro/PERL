#!/usr/bin/perl

###################################################################################
#Script:   This script converts cmf data from flat files into CPDATA2 cmf_data db #
#          Once the ETL process completes, dump is taken which gets loaded to     #
#          CPDB2, from where it gets loaded to IQ                                 #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04       Amer Khan       Originally created                                #
#11/18/04       Amer Khan       Modified to unzip file that is now received       #
#                               directly from OPS3                                #
#10/12/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}
else
{
   $standbyserver = "CPDB2";
}

#Usage Restrictions
if ($#ARGV != 0){
   #print "Usage: db_growth.pl cmf_data \n";
#   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/accents";

#Checking to see if download from pervasive went ok...

#$rmError = `rm /opt/sybase/cmf_data/*`;
print "rmError: $rmError \n";

#$cpError = `cp /opt/sybase/cmf_data/asa/*.* /opt/sybase/cmf_data/`;
print "cpError: $cpError\n";


#} #eof dont run

#} #eof dont run for temporary run

#**************************Starting cmfrevty bcp***********************#
print "*****Starting cmfrevty bcp******\n";
open (BCPFILE,">/tmp/cmfrevty.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfrevty.txt") || print "cannot open: $!\n";

$firstRow = 1;
@rowArray = ();
while (<INFILE>){
#last;
   if(/^\d\d\d\d\d\d\d\d/){
  # print "$_\n\n";
   @splitRow = split(/(.)/,$_);
   #print "My row has lenght $#splitRow : @splitRow \n\n";
   splice(@splitRow,16,0,"|"); splice(@splitRow,33,0,"|"); splice(@splitRow,50,0,"|"); splice(@splitRow,67,0,"|");
   splice(@splitRow,84,0,"|"); splice(@splitRow,101,0,"|"); splice(@splitRow,118,0,"|"); splice(@splitRow,135,0,"|");
   splice(@splitRow,152,0,"|"); splice(@splitRow,169,0,"|"); splice(@splitRow,186,0,"|"); splice(@splitRow,203,0,"|");
   splice(@splitRow,220,0,"|"); splice(@splitRow,237,0,"|"); splice(@splitRow,254,0,"|"); splice(@splitRow,271,0,"|");
   splice(@splitRow,288,0,"|"); splice(@splitRow,305,0,"|"); splice(@splitRow,322,0,"|"); splice(@splitRow,339,0,"|");
   splice(@splitRow,356,0,"|"); splice(@splitRow,373,0,"|"); splice(@splitRow,390,0,"|"); splice(@splitRow,407,0,"|");
   splice(@splitRow,424,0,"|"); splice(@splitRow,441,0,"|"); splice(@splitRow,458,0,"|"); splice(@splitRow,475,0,"|");
   splice(@splitRow,492,0,"|"); splice(@splitRow,509,0,"|"); splice(@splitRow,526,0,"|"); splice(@splitRow,543,0,"|");
   splice(@splitRow,560,0,"|"); splice(@splitRow,577,0,"|"); splice(@splitRow,594,0,"|"); splice(@splitRow,611,0,"|");
   splice(@splitRow,628,0,"|"); splice(@splitRow,645,0,"|"); splice(@splitRow,662,0,"|"); splice(@splitRow,679,0,"|");
   splice(@splitRow,692,0,"|"); splice(@splitRow,705,0,"|"); splice(@splitRow,718,0,"|"); splice(@splitRow,731,0,"|");
   splice(@splitRow,744,0,"|"); splice(@splitRow,757,0,"|"); splice(@splitRow,770,0,"|"); splice(@splitRow,783,0,"|");
   splice(@splitRow,796,0,"|"); splice(@splitRow,809,0,"|"); splice(@splitRow,822,0,"|"); splice(@splitRow,835,0,"|");
   splice(@splitRow,848,0,"|"); splice(@splitRow,861,0,"|"); splice(@splitRow,874,0,"|"); splice(@splitRow,887,0,"|");
   splice(@splitRow,900,0,"|"); splice(@splitRow,913,0,"|"); splice(@splitRow,926,0,"|"); splice(@splitRow,939,0,"|");
   splice(@splitRow,952,0,"|"); splice(@splitRow,965,0,"|"); splice(@splitRow,978,0,"|"); splice(@splitRow,991,0,"|");
   splice(@splitRow,1004,0,"|"); splice(@splitRow,1017,0,"|"); splice(@splitRow,1030,0,"|"); splice(@splitRow,1043,0,"|");
   splice(@splitRow,1056,0,"|"); splice(@splitRow,1069,0,"|"); splice(@splitRow,1082,0,"|"); splice(@splitRow,1095,0,"|");
   splice(@splitRow,1108,0,"|"); splice(@splitRow,1121,0,"|"); splice(@splitRow,1134,0,"|"); splice(@splitRow,1147,0,"|");
   splice(@splitRow,1160,0,"|"); splice(@splitRow,1173,0,"|"); splice(@splitRow,1186,0,"|"); splice(@splitRow,1199,0,"|");
   splice(@splitRow,1212,0,"|"); splice(@splitRow,1225,0,"|"); splice(@splitRow,1238,0,"|"); splice(@splitRow,1251,0,"|");
   splice(@splitRow,1264,0,"|"); splice(@splitRow,1277,0,"|"); splice(@splitRow,1290,0,"|"); splice(@splitRow,1303,0,"|");
   splice(@splitRow,1316,0,"|"); splice(@splitRow,1329,0,"|"); splice(@splitRow,1342,0,"|"); splice(@splitRow,1355,0,"|");
   splice(@splitRow,1368,0,"|"); splice(@splitRow,1381,0,"|"); splice(@splitRow,1394,0,"|"); splice(@splitRow,1407,0,"|");
   splice(@splitRow,1420,0,"|"); splice(@splitRow,1433,0,"|"); splice(@splitRow,1446,0,"|"); splice(@splitRow,1459,0,"|");
   splice(@splitRow,1472,0,"|"); splice(@splitRow,1485,0,"|"); splice(@splitRow,1498,0,"|"); splice(@splitRow,1511,0,"|");
   splice(@splitRow,1524,0,"|"); splice(@splitRow,1537,0,"|"); splice(@splitRow,1550,0,"|"); splice(@splitRow,1563,0,"|");
   splice(@splitRow,1576,0,"|"); splice(@splitRow,1589,0,"|"); splice(@splitRow,1602,0,"|"); splice(@splitRow,1615,0,"|");
   splice(@splitRow,1628,0,"|"); splice(@splitRow,1641,0,"|"); splice(@splitRow,1654,0,"|"); splice(@splitRow,1667,0,"|");
   splice(@splitRow,1680,0,"|"); splice(@splitRow,1693,0,"|"); splice(@splitRow,1706,0,"|"); splice(@splitRow,1719,0,"|");
   splice(@splitRow,1732,0,"|"); splice(@splitRow,1745,0,"|"); splice(@splitRow,1758,0,"|"); splice(@splitRow,1771,0,"|");
   splice(@splitRow,1784,0,"|"); splice(@splitRow,1797,0,"|"); splice(@splitRow,1810,0,"|"); splice(@splitRow,1823,0,"|");
   splice(@splitRow,1836,0,"|"); splice(@splitRow,1849,0,"|"); splice(@splitRow,1862,0,"|"); splice(@splitRow,1875,0,"|");
   splice(@splitRow,1888,0,"|"); splice(@splitRow,1901,0,"|"); splice(@splitRow,1914,0,"|"); splice(@splitRow,1927,0,"|");
   splice(@splitRow,1940,0,"|"); splice(@splitRow,1953,0,"|"); splice(@splitRow,1966,0,"|"); splice(@splitRow,1979,0,"|");
   splice(@splitRow,1992,0,"|"); splice(@splitRow,2005,0,"|"); splice(@splitRow,2018,0,"|"); splice(@splitRow,2031,0,"|");
   splice(@splitRow,2044,0,"|"); splice(@splitRow,2057,0,"|"); splice(@splitRow,2070,0,"|"); splice(@splitRow,2083,0,"|");
   splice(@splitRow,2096,0,"|"); splice(@splitRow,2109,0,"|"); splice(@splitRow,2122,0,"|"); splice(@splitRow,2135,0,"|");
   splice(@splitRow,2148,0,"|"); splice(@splitRow,2161,0,"|"); splice(@splitRow,2174,0,"|"); splice(@splitRow,2187,0,"|");
   splice(@splitRow,2200,0,"|"); splice(@splitRow,2217,0,"|"); splice(@splitRow,2234,0,"|"); splice(@splitRow,2251,0,"|");
   splice(@splitRow,2268,0,"|"); splice(@splitRow,2285,0,"|"); splice(@splitRow,2302,0,"|"); splice(@splitRow,2319,0,"|");
   splice(@splitRow,2336,0,"|"); splice(@splitRow,2353,0,"|"); splice(@splitRow,2370,0,"|"); splice(@splitRow,2387,0,"|");
   splice(@splitRow,2404,0,"|"); splice(@splitRow,2421,0,"|"); splice(@splitRow,2438,0,"|"); splice(@splitRow,2455,0,"|");
   splice(@splitRow,2472,0,"|"); splice(@splitRow,2489,0,"|"); splice(@splitRow,2506,0,"|"); splice(@splitRow,2523,0,"|");
   splice(@splitRow,2540,0,"|"); splice(@splitRow,2557,0,"|"); splice(@splitRow,2574,0,"|"); splice(@splitRow,2591,0,"|");
   splice(@splitRow,2608,0,"|"); splice(@splitRow,2625,0,"|"); splice(@splitRow,2642,0,"|"); splice(@splitRow,2659,0,"|");
   splice(@splitRow,2676,0,"|");

   #print "Here is the row now: @splitRow \n\n";
   foreach $row (@splitRow){
       $addRow .= $row;
   }
  # print "$addRow\n\n";

   push(@rowArray,$addRow);
      if($firstRow == 1){
         push(@rowArray,"||\n");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }
         print BCPFILE $rowToAdd;
         undef $addRow;
         undef @splitRow;
         undef $rowToAdd;
         undef @rowArray;
         #@rowArray = ();
         #print "Length of the array now: $#rowArray\n";
         next;
      }
   }else{
      if($firstRow == 0){next;}
      $_ =~ s/\0/ /g;
      $_ =~ s/\r//g;
      $_ =~ s/\n//g;
      push(@rowArray,$_);
      next;
   }

}#eof of while loop
close BCPFILE;
close INFILE;
print "***** 1 ******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -Ps9b2s3 -w300 <<EOF 2>&1 
use cmf_data
go
alter table cmfrevty drop constraint web_cmfrevty_pkey
go
truncate table cmfrevty
go
exit
EOF
bcp cmf_data..cmfrevty in /tmp/cmfrevty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfrevty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
ALTER TABLE cmfrevty
ADD CONSTRAINT web_cmfrevty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
go
exit
EOF
`;
print "reci\n";

#**************************Starting #2 cmfrevty bcp***********************#
print "*****Starting cmfrevty bcp******\n";
open (BCPFILE,">/tmp/cmfrevty.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfrevty.txt") || print "cannot open: $!\n";

$firstRow = 1;
@rowArray = ();
while (<INFILE>){
#last;
   if(/^\d\d\d\d\d\d\d\d/){
  # print "$_\n\n";
   @splitRow = split(/(.)/,$_);
   #print "My row has lenght $#splitRow : @splitRow \n\n";
   splice(@splitRow,16,0,"|"); splice(@splitRow,33,0,"|"); splice(@splitRow,50,0,"|"); splice(@splitRow,67,0,"|");
   splice(@splitRow,84,0,"|"); splice(@splitRow,101,0,"|"); splice(@splitRow,118,0,"|"); splice(@splitRow,135,0,"|");
   splice(@splitRow,152,0,"|"); splice(@splitRow,169,0,"|"); splice(@splitRow,186,0,"|"); splice(@splitRow,203,0,"|");
   splice(@splitRow,220,0,"|"); splice(@splitRow,237,0,"|"); splice(@splitRow,254,0,"|"); splice(@splitRow,271,0,"|");
   splice(@splitRow,288,0,"|"); splice(@splitRow,305,0,"|"); splice(@splitRow,322,0,"|"); splice(@splitRow,339,0,"|");
   splice(@splitRow,356,0,"|"); splice(@splitRow,373,0,"|"); splice(@splitRow,390,0,"|"); splice(@splitRow,407,0,"|");
   splice(@splitRow,424,0,"|"); splice(@splitRow,441,0,"|"); splice(@splitRow,458,0,"|"); splice(@splitRow,475,0,"|");
   splice(@splitRow,492,0,"|"); splice(@splitRow,509,0,"|"); splice(@splitRow,526,0,"|"); splice(@splitRow,543,0,"|");
   splice(@splitRow,560,0,"|"); splice(@splitRow,577,0,"|"); splice(@splitRow,594,0,"|"); splice(@splitRow,611,0,"|");
   splice(@splitRow,628,0,"|"); splice(@splitRow,645,0,"|"); splice(@splitRow,662,0,"|"); splice(@splitRow,679,0,"|");
   splice(@splitRow,692,0,"|"); splice(@splitRow,705,0,"|"); splice(@splitRow,718,0,"|"); splice(@splitRow,731,0,"|");
   splice(@splitRow,744,0,"|"); splice(@splitRow,757,0,"|"); splice(@splitRow,770,0,"|"); splice(@splitRow,783,0,"|");
   splice(@splitRow,796,0,"|"); splice(@splitRow,809,0,"|"); splice(@splitRow,822,0,"|"); splice(@splitRow,835,0,"|");
   splice(@splitRow,848,0,"|"); splice(@splitRow,861,0,"|"); splice(@splitRow,874,0,"|"); splice(@splitRow,887,0,"|");
   splice(@splitRow,900,0,"|"); splice(@splitRow,913,0,"|"); splice(@splitRow,926,0,"|"); splice(@splitRow,939,0,"|");
   splice(@splitRow,952,0,"|"); splice(@splitRow,965,0,"|"); splice(@splitRow,978,0,"|"); splice(@splitRow,991,0,"|");
   splice(@splitRow,1004,0,"|"); splice(@splitRow,1017,0,"|"); splice(@splitRow,1030,0,"|"); splice(@splitRow,1043,0,"|");
   splice(@splitRow,1056,0,"|"); splice(@splitRow,1069,0,"|"); splice(@splitRow,1082,0,"|"); splice(@splitRow,1095,0,"|");
   splice(@splitRow,1108,0,"|"); splice(@splitRow,1121,0,"|"); splice(@splitRow,1134,0,"|"); splice(@splitRow,1147,0,"|");
   splice(@splitRow,1160,0,"|"); splice(@splitRow,1173,0,"|"); splice(@splitRow,1186,0,"|"); splice(@splitRow,1199,0,"|");
   splice(@splitRow,1212,0,"|"); splice(@splitRow,1225,0,"|"); splice(@splitRow,1238,0,"|"); splice(@splitRow,1251,0,"|");
   splice(@splitRow,1264,0,"|"); splice(@splitRow,1277,0,"|"); splice(@splitRow,1290,0,"|"); splice(@splitRow,1303,0,"|");
   splice(@splitRow,1316,0,"|"); splice(@splitRow,1329,0,"|"); splice(@splitRow,1342,0,"|"); splice(@splitRow,1355,0,"|");
   splice(@splitRow,1368,0,"|"); splice(@splitRow,1381,0,"|"); splice(@splitRow,1394,0,"|"); splice(@splitRow,1407,0,"|");
   splice(@splitRow,1420,0,"|"); splice(@splitRow,1433,0,"|"); splice(@splitRow,1446,0,"|"); splice(@splitRow,1459,0,"|");
   splice(@splitRow,1472,0,"|"); splice(@splitRow,1485,0,"|"); splice(@splitRow,1498,0,"|"); splice(@splitRow,1511,0,"|");
   splice(@splitRow,1524,0,"|"); splice(@splitRow,1537,0,"|"); splice(@splitRow,1550,0,"|"); splice(@splitRow,1563,0,"|");
   splice(@splitRow,1576,0,"|"); splice(@splitRow,1589,0,"|"); splice(@splitRow,1602,0,"|"); splice(@splitRow,1615,0,"|");
   splice(@splitRow,1628,0,"|"); splice(@splitRow,1641,0,"|"); splice(@splitRow,1654,0,"|"); splice(@splitRow,1667,0,"|");
   splice(@splitRow,1680,0,"|"); splice(@splitRow,1693,0,"|"); splice(@splitRow,1706,0,"|"); splice(@splitRow,1719,0,"|");
   splice(@splitRow,1732,0,"|"); splice(@splitRow,1745,0,"|"); splice(@splitRow,1758,0,"|"); splice(@splitRow,1771,0,"|");
   splice(@splitRow,1784,0,"|"); splice(@splitRow,1797,0,"|"); splice(@splitRow,1810,0,"|"); splice(@splitRow,1823,0,"|");
   splice(@splitRow,1836,0,"|"); splice(@splitRow,1849,0,"|"); splice(@splitRow,1862,0,"|"); splice(@splitRow,1875,0,"|");
   splice(@splitRow,1888,0,"|"); splice(@splitRow,1901,0,"|"); splice(@splitRow,1914,0,"|"); splice(@splitRow,1927,0,"|");
   splice(@splitRow,1940,0,"|"); splice(@splitRow,1953,0,"|"); splice(@splitRow,1966,0,"|"); splice(@splitRow,1979,0,"|");
   splice(@splitRow,1992,0,"|"); splice(@splitRow,2005,0,"|"); splice(@splitRow,2018,0,"|"); splice(@splitRow,2031,0,"|");
   splice(@splitRow,2044,0,"|"); splice(@splitRow,2057,0,"|"); splice(@splitRow,2070,0,"|"); splice(@splitRow,2083,0,"|");
   splice(@splitRow,2096,0,"|"); splice(@splitRow,2109,0,"|"); splice(@splitRow,2122,0,"|"); splice(@splitRow,2135,0,"|");
   splice(@splitRow,2148,0,"|"); splice(@splitRow,2161,0,"|"); splice(@splitRow,2174,0,"|"); splice(@splitRow,2187,0,"|");
   splice(@splitRow,2200,0,"|"); splice(@splitRow,2217,0,"|"); splice(@splitRow,2234,0,"|"); splice(@splitRow,2251,0,"|");
   splice(@splitRow,2268,0,"|"); splice(@splitRow,2285,0,"|"); splice(@splitRow,2302,0,"|"); splice(@splitRow,2319,0,"|");
   splice(@splitRow,2336,0,"|"); splice(@splitRow,2353,0,"|"); splice(@splitRow,2370,0,"|"); splice(@splitRow,2387,0,"|");
   splice(@splitRow,2404,0,"|"); splice(@splitRow,2421,0,"|"); splice(@splitRow,2438,0,"|"); splice(@splitRow,2455,0,"|");
   splice(@splitRow,2472,0,"|"); splice(@splitRow,2489,0,"|"); splice(@splitRow,2506,0,"|"); splice(@splitRow,2523,0,"|");
   splice(@splitRow,2540,0,"|"); splice(@splitRow,2557,0,"|"); splice(@splitRow,2574,0,"|"); splice(@splitRow,2591,0,"|");
   splice(@splitRow,2608,0,"|"); splice(@splitRow,2625,0,"|"); splice(@splitRow,2642,0,"|"); splice(@splitRow,2659,0,"|");
   splice(@splitRow,2676,0,"|");

   #print "Here is the row now: @splitRow \n\n";
   foreach $row (@splitRow){
       $addRow .= $row;
   }
  # print "$addRow\n\n";

   push(@rowArray,$addRow);
      if($firstRow == 1){
         push(@rowArray,"||\n");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }
         print BCPFILE $rowToAdd;
         undef $addRow;
         undef @splitRow;
         undef $rowToAdd;
         undef @rowArray;
         #@rowArray = ();
         #print "Length of the array now: $#rowArray\n";
         next;
      }
   }else{
      if($firstRow == 0){next;}
      $_ =~ s/\0/ /g;
      $_ =~ s/\r//g;
      $_ =~ s/\n//g;
      push(@rowArray,$_);
      next;
   }

}#eof of while loop
close BCPFILE;
close INFILE;
print "***** 11 ******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfrevty drop constraint web_cmfrevty_pkey
go
truncate table cmfrevty
go
exit
EOF
bcp cmf_data..cmfrevty in /tmp/cmfrevty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfrevty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
ALTER TABLE cmfrevty
ADD CONSTRAINT web_cmfrevty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
go
exit
EOF
`;
print "At last\n";

