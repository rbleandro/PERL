#!/usr/bin/perl 

###################################################################################
#Script:   This script converts cmf data from flat files into CPDATA2 cmf_data db #
#          Once the ETL process completes, dump is taken which gets loaded to     #
#          CPDB2, from where it gets loaded to IQ                                 #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04	Amer Khan	Originally created                                #
#11/18/04	Amer Khan	Modified to unzip file that is now received       #
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
$perv_ld_msgs = `grep not \/opt\/sybase\/cron_scripts\/cron_logs\/load_perv.log`;

if ($perv_ld_msgs){
print "!!!Something is not right with Pervasive Load Job, Please investigate...!!!\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Pervasive Load Error Alert

\`head -100 \/opt\/sybase\/cron_scripts\/cron_logs\/load_perv.log\`
EOF
`;
}

#if(1==2){ #start of don't run for temporary run

print "\n**********Suspending replication and preparing to resync now...".localtime()."*************\n\n";

#***************Suspending replication and preparing to resync************
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Ssybrep1 -w300 <<EOF 2>&1
#suspend connection to $standbyserver.cmf_data
#go
#drop connection to $standbyserver.cmf_data
#go
#wait for delay '00:00:15'
#go
#exit
#EOF
#`;

print "\n".localtime().":********replication messages*********\n\n$sqlError\n";

print "\n**********Starting cmf_data load now...".localtime()."*************\n\n";

#if(1==2){ #start of don't run

$rmError = `rm /opt/sybase/cmf_data/*`;
print "rmError: $rmError \n";

$cpError = `cp /opt/sybase/cmf_data/asa/*.* /opt/sybase/cmf_data/`;
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

print "Messages from truncating and repopulating cmfrevty\n\n$sqlError\n\n";

#**************************Starting cmfclmty bcp***********************#
print "****Starting cmfclmty bcp****\n";
open (BCPFILE,">/tmp/cmfclmty.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFCLMTY.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
#   $_ =~ s/^\d\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
#print "after removing bad dates\n";
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfclmty drop constraint cmfclmty_pkey
go
truncate table cmfclmty
go
exit
EOF
bcp cmf_data..cmfclmty in /tmp/cmfclmty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfclmty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
ALTER TABLE cmfclmty
ADD CONSTRAINT cmfclmty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfclmty\n\n$sqlError\n\n";
#***************************************************************************#

#**************************Starting cmfcurrp bcp***********************#
print "****Starting cmfcurrp bcp****\n";

open (BCPFILE,">/tmp/cmfcurrp.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfcurrp.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfcurrp drop constraint cmfcurrp_pkey
go
truncate table cmfcurrp
go
exit
EOF
bcp cmf_data..cmfcurrp in /tmp/cmfcurrp.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfcurrp.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from cmfcurrp) > 1)
ALTER TABLE cmfcurrp
ADD CONSTRAINT cmfcurrp_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfcurrp"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfcurrp\n\n$sqlError\n\n";

#**************************Starting cmforvty bcp***********************#
print "****Starting cmforvty bcp*****\n";

open (BCPFILE,">/tmp/cmforvty.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmforvty.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmforvty drop constraint cmforvty_pkey
go
truncate table cmforvty
go
exit
EOF
bcp cmf_data..cmforvty in /tmp/cmforvty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmforvty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
ALTER TABLE cmforvty
ADD CONSTRAINT cmforvty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
go
exit
EOF
`;

print "Messages from truncating and repopulating cmforvty\n\n$sqlError\n\n";
#*****************************************************************************#
#}#eof dont run

#**************************Starting cmfpcsty bcp***********************#
print "******Starting cmfpcsty bcp******\n";

open (BCPFILE,">/tmp/cmfpcsty.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFPCSTY.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
#   $_ =~ s/^\d\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfpcsty drop constraint cmfpcsty_pkey
go
truncate table cmfpcsty
go
exit
EOF
bcp cmf_data..cmfpcsty in /tmp/cmfpcsty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfpcsty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
ALTER TABLE cmfpcsty
ADD CONSTRAINT cmfpcsty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfpcsty\n\n$sqlError\n\n";
#***************************************************************************#

if(1==2){ #start of don't run

#**************************Starting cmfsales bcp***********************#
print "******Starting cmfsales bcp*******\n";

open (BCPFILE,">/tmp/cmfsales.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFSALES.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmfsales drop constraint cmfsales_pkey
#go
#truncate table cmfsales
#go
#exit
#EOF
#bcp cmf_data..cmfsales in /tmp/cmfsales.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfsales.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmfsales) > 1)
#ALTER TABLE cmfsales
#ADD CONSTRAINT cmfsales_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmfsales"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmfsales\n\n$sqlError\n\n";

#} #eof dont run

#**************************Starting rc_zones bcp***********************#
print "****Starting rc_zones bcp*****\n";

open (BCPFILE,">/tmp/rc_zones.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/zones.txt") || print "cannot open: $!\n";
#create array for consecutive header rows
@header_arr = ();
$reset_header = "n";

while (<INFILE>){
#last;
   next if /^\D/;
   $is_header="n";
   $_ =~ s/^\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   #Save first 5 chars into a var
   $zone_name=substr($_,0,5);
   $zone_version = substr($_,5,1);
   $is_header="y" if substr($_,8,1) eq "1";

   if ($is_header eq "y"){
      if ($reset_header eq "y"){
      #   print "Resetting Header now...\n";
         undef @header_arr;
         $reset_header = "n";
      }
      $f_fsa1 = substr($_,9,5);
      $f_fsa1 =~ s/\s//g;
      $f_fsa2 = substr($_,14,5);
      $f_fsa2 =~ s/\s//g;

      if (length($f_fsa1) == 1){
         $from_fsa1 = $f_fsa1."0A";
      }else{
         if (length($f_fsa1) == 2){
            $from_fsa1 = $f_fsa1."A";
         }else{
            $from_fsa1 = $f_fsa1;
         }
      }
      if (length($from_fsa2) == 1){
         $from_fsa2 = $f_fsa2."9Z";
      }else{
         if (length($f_fsa2) == 2){
            $from_fsa2 = $f_fsa2."Z";
         }else{
            if (length($f_fsa2) == 0){
		if (length($f_fsa1) > 2) {
                  $from_fsa2 = $f_fsa1;
	        } else {
                 $from_fsa2 = substr($f_fsa1,0,1)."9Z";
             }
            }else{
               $from_fsa2 = $f_fsa2;
            }
         }
      }
      push(@header_arr,$from_fsa1,$from_fsa2);
   }else{ #it is not a header
      $rate_zone = substr($_,20,2);
      $origin = substr($_,6,1);
      $originsub = substr($_,7,1);
      $reset_header = "y";
      $fsa1 = substr($_,9,5);
      $fsa1 =~ s/\s//g;
      $fsa2 = substr($_,14,5);
      $fsa2 =~ s/\s//g;

      if (length($fsa1) == 3 && length($fsa2) == 0){
         $to_fsa2 = $fsa1;
	 $to_fsa1 = $fsa1;
      }else{
         if (length($fsa1) < 3 && length($fsa2) == 0){
            if (length($fsa1) == 2){
               $to_fsa1 = $fsa1."A";
               $to_fsa2 = $fsa1."Z";
            }else{
               $to_fsa1 = $fsa1."0A";
               $to_fsa2 = $fsa1."9Z";
            }
         }else{
            if (length($fsa1) > 0 && length($fsa1) < 3 && length($fsa2) > 0 && length($fsa2) < 3){
               if (length($fsa1) == 2 && length($fsa2) == 2){
                  $to_fsa1 = $fsa1."A";
                  $to_fsa2 = $fsa2."Z";
               }
            }else{
               $to_fsa1 = $fsa1;
               $to_fsa2 = $fsa2;
            }
         }
      }

      $cnt = 0;
      foreach (@header_arr){
         $cnt++;
         $is_it_fr_fsa2 = $cnt % 2; #0 means yes!
         if ($is_it_fr_fsa2 == 0){
            print BCPFILE "$zone_name|$zone_version|$fr_fsa1|$_|$to_fsa1|$to_fsa2|$rate_zone|$origin|$originsub\n";
         }else{
            $fr_fsa1 = $_;
         }
      }
   }#eof it is a detail row
}#eof while loop
close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table rc_zones drop constraint ground_rate_pk1
go
truncate table rc_zones
go
exit
EOF
bcp cmf_data..rc_zones in /tmp/rc_zones.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/rc_zones.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from rc_zones) > 1)
ALTER TABLE rc_zones
ADD CONSTRAINT ground_rate_pk1
PRIMARY KEY CLUSTERED (zone_name,zone_version,from_fsa_1,from_fsa_2,to_fsa_1,to_fsa_2,rate_zone)--,origin,originsub)
else
select "No data in table: rc_zones"
go
exit
EOF
`;

print "Messages from truncating and repopulating rc_zones\n\n$sqlError\n\n";
#**********************************************************************************************
} #eof of don't run

#**************************Starting pts_served bcp***********************#
#print "****Starting pts_served bcp*****\n";

#open (BCPFILE,">/tmp/pts_served.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/cmf_data/pntserved.txt") || print "cannot open: $!\n";

#$firstRow = 1;
#@rowArray = ();
#while (<INFILE>){
#last;
#   $_ =~ s/^\d\d,//;
#   if(/^\d\d\d/){
#   $_ =~ s/\0/ /g;
#   $_ =~ s/\r//g;
#   $_ =~ s/\n//g;
#  #print "$_\n\n";
#   @splitRow = split(/(.)/,$_);
#  #print "My row has lenght $#splitRow : @splitRow \n\n";
#   splice(@splitRow,6,0,"|"); splice(@splitRow,13,0,"|"); splice(@splitRow,74,0,"|"); splice(@splitRow,77,0,"|");
#   splice(@splitRow,80,0,"|"); splice(@splitRow,91,0,"|"); splice(@splitRow,102,0,"|"); splice(@splitRow,115,0,"|");
#   splice(@splitRow,120,0,"|"); splice(@splitRow,127,0,"|");
#
#
#   foreach $row (@splitRow){
#       $addRow .= $row;
#   }
#  #print "$addRow\n\n";
#
#   push(@rowArray,$addRow);
#      if($firstRow == 1){
#         push(@rowArray,"||\n");
#         foreach $line (@rowArray){
#            $rowToAdd .= $line;
#         }
#         print BCPFILE $rowToAdd;
#         undef $addRow;
#         undef @splitRow;
#         undef $rowToAdd;
#         undef @rowArray;
#         next;
#      }
#   }else{
#      if($firstRow == 0){next;}
#      $_ =~ s/\0/ /g;
#      $_ =~ s/\r//g;
#      $_ =~ s/\n//g;
#      if(/^\s/){next;}
#      push(@rowArray,$_);
#      next;
#   }
#
#}#eof of while loop
#close BCPFILE;
#close INFILE;
#
#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table pts_served
#go
#exit
#EOF
#bcp cmf_data..pts_served in /tmp/pts_served.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/pts_served.fmt -Q
#`;


#print "Messages from truncating and repopulating pts_served\n\n$sqlError\n\n";

#**********************************************************************************************
#} #eof dont run
#**********************************************************************************************
print "****Starting ara_letr bcp*****\n";

open (BCPFILE,">/tmp/ara_letr.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_letr.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_letr
go
exit
EOF
bcp cmf_data..ara_letr in /tmp/ara_letr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_letr.fmt -Q
`;


print "Messages from truncating and repopulating ara_letr\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_numb bcp*****\n";

open (BCPFILE,">/tmp/ara_numb.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_numb.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_number
go
exit
EOF
bcp cmf_data..ara_number in /tmp/ara_numb.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_numb.fmt -Q
`;


print "Messages from truncating and repopulating ara_numb\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_purs bcp*****\n";

open (BCPFILE,">/tmp/ara_purs.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_purs.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
if (/(.........................)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(.........................)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }

while (/(\/)(\D\D)(\/)/){
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /;
}


if (/(\/)([23456789]{1}\d)(\/)/){ #Don't write bad dates
   $_ =~ s/(....)(\/)([23456789]{1}\d)(\/)(..)/          /;
}

if (/(\/)(\d\d)(\/)(\D\D)/){
   $_ =~ s/(....)(\/)(\d\d)(\/)(\D\D)/          /;
}

next if (!/^.....................\d\d\d\d/); #Skip bad data


next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_purs
go
exit
EOF
bcp cmf_data..ara_purs in /tmp/ara_purs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_purs.fmt -Q -m1 -b10
`;


print "Messages from truncating and repopulating ara_purs\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_srce bcp*****\n";

open (BCPFILE,">/tmp/ara_srce.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_srce.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_source
go
exit
EOF
bcp cmf_data..ara_source in /tmp/ara_srce.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_srce.fmt -Q
`;


print "Messages from truncating and repopulating ara_srce\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_actn bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_action
go
exit
EOF
bcp cmf_data..ara_action in /opt/sybase/cmf_data/ara_actn.txt -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_actn.fmt -Q
`;

print "Messages from truncating and repopulating ara_actn\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_comm bcp*****\n";

open (BCPFILE,">/tmp/ara_comm.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_comm.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_comments
go
exit
EOF
bcp cmf_data..ara_comments in /tmp/ara_comm.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_comm.fmt -Q
`;


print "Messages from truncating and repopulating ara_comm\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run
#**********************************************************************************************
print "****Starting ara_caus bcp*****\n";

open (BCPFILE,">/tmp/ara_caus.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_caus.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
#Converting french characters from ANSI to ASCII types...  
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_cause
go
exit
EOF
bcp cmf_data..ara_cause in /tmp/ara_caus.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_caus.fmt -Q
`;


print "Messages from truncating and repopulating ara_caus\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run
#**********************************************************************************************
print "****Starting ara_clrk bcp*****\n";

open (BCPFILE,">/tmp/ara_clrk.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_clrk.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
#Converting french characters from ANSI to ASCII types...  
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_clerk
go
exit
EOF
bcp cmf_data..ara_clerk in /tmp/ara_clrk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_clrk.fmt -Q
`;


print "Messages from truncating and repopulating ara_clrk\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run


if(1==2){ #start of don't run for temporary run

#**********************************************************************************************
print "****Starting cparf06i bcp*****\n";

open (BCPFILE,">/tmp/cparf06i.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CPARF06I.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
#next if (!/^45,42085166/);
   $_ =~ s/^\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r{1}$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n//g;

#Converting french characters from ANSI to ASCII types...  
   #$_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################

if (/(............)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(............)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }

if (/(..............................................)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(..............................................)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }

while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /;
#   print "$_\n";
}

if (/(\/)([23456789]{1}\d)(\/)/){ #Don't write bad dates
   $_ =~ s/(....)(\/)([23456789]{1}\d)(\/)(..)/          /;
}

if (/(\/)(\d\d)(\/)(\D\D)/){
   $_ =~ s/(....)(\/)(\d\d)(\/)(\D\D)/          /;
}

#next if (!/^..............\d\d\d\d/); #Skip bad data
#print BCPFILE "Wroking on: $_\n";
#if (/(..................)(.)(.)(.)(.)(.)(.)(.)(.)/){
#   if ($2 !~ /\d/ || $3 !~ /\d/ || $4 !~ /\d/ || $5 !~ /\d/ || $6 !~ /\d/ || $7 !~ /\d/ || $8 !~ /\d/ || $9 !~ /\d/){
#      $_ =~ s/(..................)(........)/$1        /;
#   }
#}

next if(/^\s\s/ || /^\W/); #Don't write if it is an empty line
next if (length($_) < 59);

while (/(^........)(\S\S\S\s\s)/){
   $_ =~ s/(^........)(\S\S\S\s\s)/$1     /;
}

if (/(^..........................................)(.)/){
   if (($2 < 1 || $2 > 2) && $2 !~ /\s/){
      $_ =~ s/(^..........................................)(.)/$1."2"/e;
   }
}

#Add a decimal for the numeric data
if (/(^.{18})(...........)/){
   $mynum = $2/100;
   $diff = 11 - length($mynum);
   for ($i=0;$i < $diff; $i++){
      $mynum = " ".$mynum;
   }
}

$_ =~ s/(^.{18})(.{11})/$1.$mynum/e;

#Add a decimal for the numeric data
if (/(^.{29})(...........)/){
   $mynum = $2/100;
   $diff = 11 - length($mynum);
   for ($i=0;$i < $diff; $i++){
      $mynum = " ".$mynum;
   }
}

$_ =~ s/(^.{29})(.{11})/$1.$mynum/e;


print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06i') AND name='cust_org_amt_nc')
#BEGIN
#DROP INDEX cparf06i.cust_org_amt_nc
#IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06i') AND name='cust_org_amt_nc')
#PRINT '<<< FAILED DROPPING INDEX dbo.cparf06i.cust_org_amt_nc >>>'
#ELSE
#PRINT '<<< DROPPED INDEX dbo.cparf06i.cust_org_amt_nc >>>'
#END
#go   
#truncate table cparf06i
#go
#exit
#EOF
#bcp cmf_data..cparf06i in /tmp/cparf06i.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cparf06i.fmt -m0 -b10000 -Q
#`;

#$sqlError1 = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#CREATE NONCLUSTERED INDEX cust_org_amt_nc
#ON dbo.cparf06i(customer,original_amt)
#go   
#exit
#EOF
#`;

#print "$sqlError1\n";
#print "Messages from truncating and repopulating cparf06i\n\n$sqlError\n\n";
#**********************************************************************************************
} # eof dont run

if(1==2){ #start of don't run for temporary run

#**********************************************************************************************
print "****Starting cparf06p bcp*****\n";

open (BCPFILE,">/tmp/cparf06p.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CPARF06P.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d{18}//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r{1}$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n//g;

   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################

if (/(............)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(............)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }

if (/(^....................................)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(^....................................)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }

while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /;
#   print "$_\n";
}

if (/(\/)([23456789]{1}\d)(\/)/){ #Don't write bad dates
   $_ =~ s/(....)(\/)([23456789]{1}\d)(\/)(..)/          /;
}

if (/(\/)(\d\d)(\/)(\D\D)/){
   $_ =~ s/(....)(\/)(\d\d)(\/)(\D\D)/          /;
}

#next if (!/^..............\d\d\d\d/); #Skip bad data
#print BCPFILE "Wroking on: $_\n";
#if (/(^.....................)(.)(.)(.)(.)/){
#   if ($2 !~ /\d/ || $3 !~ /\d/ || $4 !~ /\d/ || $5 !~ /\d/){
#      $_ =~ s/(^.....................)(....)/$1    /;
#   }
#}

#print BCPFILE "Final Result: $_\n";
next if(/^\s\s/ || /^\W/); #Don't write if it is an empty line
next if (length($_) < 35);

while (/(^........)(\S\S\S\s\s)/){
   #print "working on: $_\n";
   #print "Found a bad date: $1$2\n";
   $_ =~ s/(^........)(\S\S\S\s\s)/$1     /;
#   print "$_\n";
}

if (/(^................................)(.)/){
   if (($2 < 1 || $2 > 2) && $2 !~ /\s/){
      $_ =~ s/(^................................)(.)/$1."2"/e;
   }
}

#Add a decimal for the numeric data
if (/(^.{21})(...........)/){
   $mynum = $2/100;
   $diff = 11 - length($mynum);
   for ($i=0;$i < $diff; $i++){
      $mynum = " ".$mynum;
   }
}

$_ =~ s/(^.{21})(.{11})/$1.$mynum/e;


print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06p') AND name='cust_nc')
#BEGIN
#DROP INDEX cparf06p.cust_nc
#IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06p') AND name='cust_nc')
#PRINT '<<< FAILED DROPPING INDEX dbo.cparf06p.cust_nc >>>'
#ELSE
#PRINT '<<< DROPPED INDEX dbo.cparf06p.cust_nc >>>'
#END
#go   
#truncate table cparf06p
#go
#exit
#EOF
#bcp cmf_data..cparf06p in /tmp/cparf06p.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cparf06p.fmt -m0 -b10000 -Q
#`;

#$sqlError1 = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#CREATE NONCLUSTERED INDEX cust_nc
#ON dbo.cparf06p(customer,invoice_date)
#go   
#exit
#EOF
#`;

#print "$sqlError1\n";

#print "Messages from truncating and repopulating cparf06p\n\n$sqlError\n\n";
#**********************************************************************************************
} # eof dont run

if (1==2){ #The following tables does not need to run every day
#**************************Starting cmfrev98 bcp***********************#
print "*****Starting cmfrev98 bcp******\n";
open (BCPFILE,">/tmp/cmfrev98.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfrev98.txt") || print "cannot open: $!\n";

$firstRow = 1;
@rowArray = ();
while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d\d,//;
   if(/^\d\d\d\d\d\d\d\d/){
   $_ =~ s/\0/ /g;
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
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

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfrev98 drop constraint web_cmfrev98_pkey
go
truncate table cmfrev98
go
exit
EOF
bcp cmf_data..cmfrev98 in /tmp/cmfrev98.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfrev98.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from cmfrev98) > 1)
ALTER TABLE cmfrev98
ADD CONSTRAINT web_cmfrev98_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfrev98"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfrev98\n\n$sqlError\n\n";
#*************************************************************************************
#} #eof dont run
#**************************Starting cmfpcs03 bcp***********************#
print "******Starting cmfpcs03 bcp******\n";

open (BCPFILE,">/tmp/cmfpcs03.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfpcs03.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfpcs03 drop constraint cmfpcs03_pkey
go
truncate table cmfpcs03
go
exit
EOF
bcp cmf_data..cmfpcs03 in /tmp/cmfpcs03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfpcs03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from cmfpcs03) > 1)
ALTER TABLE cmfpcs03
ADD CONSTRAINT cmfpcs03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfpcs03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfpcs03\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting cmfclm03 bcp***********************#
print "****Starting cmfclm03 bcp****\n";
open (BCPFILE,">/tmp/cmfclm03.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfclm03.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
#print "after removing bad dates\n";
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfclm03 drop constraint cmfclm03_pkey
go
truncate table cmfclm03
go
exit
EOF
bcp cmf_data..cmfclm03 in /tmp/cmfclm03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfclm03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from cmfclm03) > 1)
ALTER TABLE cmfclm03
ADD CONSTRAINT cmfclm03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfclm03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfclm03\n\n$sqlError\n\n";
#***************************************************************************

#**************************Starting cmforv03 bcp***********************#
print "****Starting cmforv03 bcp****\n";

open (BCPFILE,">/tmp/cmforv03.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmforv03.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmforv03 drop constraint cmforv03_pkey
go
truncate table cmforv03
go
exit
EOF
bcp cmf_data..cmforv03 in /tmp/cmforv03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmforv03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from cmforv03) > 1)
ALTER TABLE cmforv03
ADD CONSTRAINT cmforv03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmforv03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmforv03\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting cmfrev03 bcp***********************#
print "*****Starting cmfrev03 bcp******\n";
open (BCPFILE,">/tmp/cmfrev03.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfrev03.txt") || print "cannot open: $!\n";

$firstRow = 1;
@rowArray = ();
while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d\d,//;
   if(/^\d\d\d\d\d\d\d\d/){
   $_ =~ s/\0/ /g;
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
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

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table cmfrev03 drop constraint web_cmfrev03_pkey
go
truncate table cmfrev03
go
exit
EOF
bcp cmf_data..cmfrev03 in /tmp/cmfrev03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfrev03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from cmfrev03) > 1)
ALTER TABLE cmfrev03
ADD CONSTRAINT web_cmfrev03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfrev03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfrev03\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting flashf00 bcp***********************#
print "*****Starting flashf00 bcp******\n";
open (BCPFILE,">/tmp/flashf00.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/asa/FLASHF00.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   print BCPFILE $_;

}#eof of while loop
close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table flashf00
go
exit
EOF
bcp cmf_data..flashf00 in /tmp/flashf00.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/flashf00.fmt -Q
`;

print "Messages from truncating and repopulating flashf00\n\n$sqlError\n\n";
#**********************************************************************************************
#}#eof dont run

#**************************Starting flashtbl bcp***********************#
print "*****Starting flashtbl bcp******\n";
open (BCPFILE,">/tmp/flashtbl.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/asa/FLASHTBL.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   print BCPFILE $_;

}#eof of while loop
close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table flashtbl
go
exit
EOF
bcp cmf_data..flashtbl in /tmp/flashtbl.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/flashtbl.fmt -Q
`;

print "Messages from truncating and repopulating flashtbl\n\n$sqlError\n\n";
#**********************************************************************************************
}#eof dont run...The tables above do not need to be loaded every day!!!

#**********************************************************************************************
#print "****Starting old_rurpers bcp*****\n";
#
#open (BCPFILE,">/tmp/old_rurpers.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/cmf_data/RURPERS.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
##last;
#   $_ =~ s/^\d\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r//g;
#   $_ =~ s/\n//g;
#   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row
#
#####################################################
#next if(/^\s\s/); #Don't write if it is an empty line
#print BCPFILE $_;
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table old_rurpers
#go
#exit
#EOF
#bcp cmf_data..old_rurpers in /tmp/old_rurpers.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/old_rurpers.fmt -Q
#
#
## Following bcp is for MS Sql Server Nightly Load ====> Leave the following uncommented for MS Sql server load. Amer
$sqlError = `. /opt/sybase/SYBASE.sh
bcp cmf_data..rurpers out /tmp/rurpersMS.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"\n"
`;

#**********************************************************************************************
#} #eof dont run

if(1==2){ #start of don't run

#**********************************************************************************************
print "****Starting cmf_baudit_hdr bcp*****\n";

open (BCPFILE,">/tmp/cmf_baudit_hdr.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFBAUDM.TXT") || print "cannot open: $!\n";
$firstRow = 0;
while (<INFILE>){

   if(/^\d\d\d\d\d\d\d\d/){

      $_ =~ s/^(........)(\W\W)/$1  /g;

      if($firstRow == 1){
         push(@rowArray,"||||");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }

         $rowToAdd =~ s/\|\:\:/\r/g;
         $rowToAdd =~ s/\|\:\|/\n/g;
         $rowToAdd =~ s/\n\|\|\|\|$/\|\|\|\|/g; # Remove the last, as we are inserting a new one
         $rowToAdd =~ s/\|\|\|\|/||\n/g;
#         $rowToAdd =~ s/\|\:/\r/g;

         if (length($rowToAdd) < 2500){
            #print "Length: ".length($rowToAdd)."\n";
            #print "Row: $rowToAdd \n";
            $rowToAdd =~ s/\|\|$//;
            #print "Row: $rowToAdd \n";
         }

         print BCPFILE $rowToAdd;
         undef $rowToAdd;
         undef @rowArray;
         #@rowArray = ();
         #print "Length of the array now: $#rowArray\n";
      }
   $firstRow = 1;
   $_ =~ s/\0/ /g;
   $_ =~ s/\r/|::/g;
   $_ =~ s/\n/|:|/g;

   push(@rowArray,$_);
   next;
   }else{
   #print  substr($_,0,8).":".substr($_,8,1)."\n";
      if($firstRow == 0){next;}
      $_ =~ s/\0/ /g;
      $_ =~ s/\r/|::/g;
      $_ =~ s/\n/|:|/g;
#      $_ =~ s/\015/|:/g;
#   if (/\015/){ print "Found one: $_\n";}

      push(@rowArray,$_);
      next;
   }

}#eof of while loop

# Insert the last line into the file as well

 if($firstRow == 1){
         push(@rowArray,"||||");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }
         $rowToAdd =~ s/\|\:\:/\r/g;
         $rowToAdd =~ s/\|\:\|/\n/g;
         $rowToAdd =~ s/\n\|\|\|\|$/||||/g; # Remove the last, as we are inserting a new one
         $rowToAdd =~ s/\|\|\|\|/||\n/g;
#         $rowToAdd =~ s/\|\:/\r/g;

         print BCPFILE $rowToAdd;
         undef $rowToAdd;
         undef @rowArray;
      }


close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmf_baudit_hdr
#go
#exit
#EOF
#bcp cmf_data..cmf_baudit_hdr in /tmp/cmf_baudit_hdr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_baudit_hdr.fmt -m0 -b1000 -Q
#`;

print "Messages from truncating and repopulating cmf_baudit_hdr\n\n$sqlError\n\n";
#**********************************************************************************************

#} #eof dont run

#**************************Starting rc_rates bcp***********************#
print "****Starting rc_rates bcp*****\n";

open (BCPFILE,">/tmp/rc_rates.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/rates.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   #$_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   $sum = 5;
   $j = 15;
   $sm_flag = 0;
   $zone = 1;
   $count = 0;
   $weight = 0;
   $rate = "";
   #print "Orig Row:\n$_\n";
   for ($i=0; $i < 40; $i++){
      #print "for loop begins\n";
      $rate = substr($_,$j,$sum);
      #print "rate: $rate\n";
      if ($rate ne "00000"){
      #print "rate is 0\n";
         $weight = substr($_,11,4);
         if($i == 20){
            $sm_flag = 1;
            $zone = 1;
         }
         $line = substr($_,4,5)."|".substr($_,9,1)."|".substr($_,10,1)."|".int($weight)."|".$sm_flag."|".$zone."|".int(substr($rate,0,3))."\.".substr($rate,3,2)."\n";
         $count++;
         $zone++;
         if ($line !~ /^\|/){
         print BCPFILE $line;
         }
         #print "Line is: ".$line."\n";
      }
      $j += $sum;
   }

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
alter table rc_rates drop constraint rc_rates_pk
go
truncate table rc_rates
go
exit
EOF
bcp cmf_data..rc_rates in /tmp/rc_rates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/rc_rates.fmt -m0 -b10000 -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
if((select count(*) from rc_rates) > 1)
ALTER TABLE rc_rates
ADD CONSTRAINT rc_rates_pk
PRIMARY KEY CLUSTERED (rate_name,KorL,version,weight,sm_flag,zone)
else
select "No data in table: rc_rates"
go
exit
EOF
`;

print "Messages from truncating and repopulating rc_rates\n\n$sqlError\n\n";
#**********************************************************************************************
} #eof dont run

if(1==2){ #start of don't run

#**********************************************************************************************
print "****Starting cmf_baudit_dtls bcp*****\n";

open (BCPFILE,">/tmp/cmf_baudit_dtls.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFBAUDD.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
#   $_ =~ s/^\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################

while (/(\/\/)/){
   $_ =~ s/\/\//  /g;
}


print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmf_baudit_dtls
#go
#exit
#EOF
#bcp cmf_data..cmf_baudit_dtls in /tmp/cmf_baudit_dtls.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_baudit_dtls.fmt -m0 -b10000 -Q
#`;

print "Messages from truncating and repopulating cmf_baudit_dtls\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting cmf_change_reqs bcp*****\n";

open (BCPFILE,">/tmp/cmf_change_reqs.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/cmfchnge.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n";

# Modify date to sybase acceptable date
   $_ =~ s/(^...........................)(..)(..)/$1\/$2\/$3/;
# There is also time here with the date so that has to be fixed as well
   $_ =~ s/(^.................................)(........)/$1 $2/;
# Fix bad time
   $_ =~ s/(^....................................)(.)(..)(.)/$1:$3:/;
####################################################
next if(!/^\d\d\d\d\d\d\d\d/); #Don't write if it is an empty line
#next if(length($_) < 68);

while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /g;
#   print "$_\n";
}

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmf_change_reqs
#go
#exit
#EOF
#bcp cmf_data..cmf_change_reqs in /tmp/cmf_change_reqs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_change_reqs.fmt -m0 -b1000 -Q
#`;

print "Messages from truncating and repopulating cmf_change_reqs\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting cmf_security bcp*****\n";

open (BCPFILE,">/tmp/cmf_security.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFSECUR.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmf_security
#go
#exit
#EOF
#bcp cmf_data..cmf_security in /tmp/cmf_security.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_security.fmt -m0 -b1000 -Q
#`;

print "Messages from truncating and repopulating cmf_security\n\n$sqlError\n\n";
#**********************************************************************************************

} #eof dont run

#**********************************************************************************************
print "****Starting tddate bcp*****\n";

open (BCPFILE,">/tmp/tddate.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/tddate.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

# Modify date to sybase acceptable date
   $_ =~ s/(^.............)(..)(..)/$1\/$2\/$3/;

# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /g;
}
while (/(\/)(.\D)(\/)/){
# More bad data to be removed
   $_ =~ s/(^.........)(....)(\/)(.\D)(\/)(..)/$1          /g;
#   print "$_\n";
}
   $_ =~ s/(^.........)(....)(\/)(..)(\/)(\s.)/$1          /g;

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table tddate
go
exit
EOF
bcp cmf_data..tddate in /tmp/tddate.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/tddate.fmt -m0 -b10000 -Q > /tmp/tddate.out
tail -2 /tmp/tddate.out
`;

print "Messages from truncating and repopulating tddate\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tmtrace bcp*****\n";

open (BCPFILE,">/tmp/tmtrace.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/tmtrace.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

# Modify date to sybase acceptable date
   $_ =~ s/(^..............)(..)(..)/$1\/$2\/$3/;

# Modify second date...
   $_ =~ s/(^...................................................................)(..)(..)/$1\/$2\/$3/;

# Modify third date...
   $_ =~ s/(^.....................................................................................................................................................................................................................)(..)(..)/$1\/$2\/$3/;

# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /g;
}
while (/(\/)(.\D)(\/)/){
# More bad data to be removed
   $_ =~ s/(^.+)(\/)(.\D)(\/)(..)/$1          /g;
#   print "$_\n";
}
   $_ =~ s/(^.+)(\/)(..)(\/)(\s.)/$1          /g;

   $_ =~ s/\s\.00/0.00/g;

# Convert french characters...
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

# Fix bad money...
   $badMoney = substr($_,244,8);
if ($badMoney =~ /\d\s\./){
   #print "Bad One: $_\n";
   $fixedMoney = $badMoney;
   $fixedMoney =~ s/(.)(.)(.)(.)(.)(.)(.)(.)/$4$1$2$3$5$6$7$8/;
   $_ =~ s/(^.+)($badMoney)/$1.$fixedMoney/e;
}


# Fix bad money...
   $badMoney = substr($_,266,8);

if ($badMoney =~ /\D\D$/ && $badMoney !~ /\W\W$/){
#print "Here is my bad money: $badMoney \n";
   #print "Bad One: $_\n";
   $fixedMoney = $badMoney;
   $fixedMoney =~ s/(.)(.)(.)(.)(.)(.)(.)(.)/$1$2$3$4$5/;
#print "fixedMoney $fixedMoney \n";
   $_ =~ s/(^.+)($badMoney)/$1.$fixedMoney/e;
#print "Fixed $fixedMoney \n";
}


####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table tmtrace
go
exit
EOF
bcp cmf_data..tmtrace in /tmp/tmtrace.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/tmtrace.fmt -m100 -b1000 -Q
`;

print "Messages from truncating and repopulating tmtrace\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tyclaim bcp*****\n";

open (BCPFILE,">/tmp/tyclaim.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/tyclaim.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

# Modify date to sybase acceptable date
   $_ =~ s/(^....................)(..)(..)/$1\/$2\/$3/;

# Modify second date...
   $_ =~ s/(^..............................................................)(..)(..)/$1\/$2\/$3/;


# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /g;
}
while (/(\/)(.\D)(\/)/){
# More bad data to be removed
   $_ =~ s/(^.+)(\/)(.\D)(\/)(..)/$1          /g;
#   print "$_\n";
}
   $_ =~ s/(^.+)(\/)(..)(\/)(\s.)/$1          /g;

   $_ =~ s/\s\.00/0.00/g;

# Convert french characters...
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

# Skip if no tynumb
   next if (/^\s\s/);

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table tyclaim
go
exit
EOF
bcp cmf_data..tyclaim in /tmp/tyclaim.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/tyclaim.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tyclaim\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tppack bcp*****\n";

open (BCPFILE,">/tmp/tppack.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/tppack.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";


# Convert french characters...
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

# Skip if no tynumb
   next if (/^\s\s/);

####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table tppack
go
exit
EOF
bcp cmf_data..tppack in /tmp/tppack.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/tppack.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tppack\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting txpost bcp*****\n";

open (BCPFILE,">/tmp/txpost.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/txpost.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

# Filter out filler at the end...
   $_ =~ s/(^.{68})(\s{15})/$1/;

####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table txpost
go
exit
EOF
bcp cmf_data..txpost in /tmp/txpost.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/txpost.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating txpost\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tbcall bcp*****\n";

open (BCPFILE,">/tmp/tbcall.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/tbcall.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

# Convert french characters...
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

# Modify date to sybase acceptable date
   $_ =~ s/(^............)(..)(..)/$1\/$2\/$3/;
# There is also time here with the date so that has to be fixed as well
   $_ =~ s/(^..................)(..)(..)/$1 $2:$3/;
# Fix bad time
   $_ =~ s/(^.....................\:)(\D)(.)/$1."0".$3/e;
   $_ =~ s/(^.......................)(\D)/$1."0"/e;
   $_ =~ s/(^...................)([3456789])/$1."0"/e;
   $_ =~ s/(^....................)(\D)/$1."0"/e;

####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table tbcall
go
exit
EOF
bcp cmf_data..tbcall in /tmp/tbcall.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/tbcall.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating tbcall\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting t3rdprt bcp*****\n";

open (BCPFILE,">/tmp/t3rdprt.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/t3rdprt.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

# Convert french characters...
   $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table t3rdprt
go
exit
EOF
bcp cmf_data..t3rdprt in /tmp/t3rdprt.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/t3rdprt.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating t3rdprt\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting trcl_comments bcp*****\n";

open (BCPFILE,">/tmp/trcl_comments.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/TRCL_COM.TXT") || print "cannot open: $!\n";

#$firstLine = 1;
#while (<INFILE>){
#last;
   # Convert french characters...
#      $_ =~ s/(\W)/defined $ASC{unpack('C*',$1)} ? pack('C*',$ASC{unpack('C*',$1)}) : pack('C*',unpack('C*',$1))/ge;

#   if ($firstLine == 1){
#      $_ =~ s/^\d\d\d,//;
#      $firstLine = 0;
#      $_ =~ s/\0/ /g; #Control characters to be taken out
#      $_ =~ s/\r/ /g;
#      $_ =~ s/\n/ /g;
#      #$_ =~ s/^(........)(\W\W)/$1  /g;
#      $row = $_;
#      next;
#   }else{
#      if (/^\w\d\d\d\d\d\d\d/){
#         if($row !~ /^\s/){
#            print BCPFILE $row."\n";
#         }
#         #$_ =~ s/^\d\d\d,//;
#         $_ =~ s/\0/ /g; #Control characters to be taken out
#         $_ =~ s/\r/ /g;
#         $_ =~ s/\n/ /g;
#         #$_ =~ s/^(........)(\W\W)/$1  /g;
#         $row = $_;
#         next;
#      }
#   }
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;

####################################################
#$row .= $_;
#}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table trcl_comments
go
exit
EOF
bcp cmf_data..trcl_comments in /opt/sybase/cmf_data/TRCL_COM.TXT -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n" -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating trcl_comments\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tspecil bcp*****\n";

open (BCPFILE,">/tmp/tspecil.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/tspecil.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table tspecil
go
exit
EOF
bcp cmf_data..tspecil in /tmp/tspecil.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/tspecil.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tspecil\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting flash_master bcp*****\n";

open (BCPFILE,">/tmp/flash_master.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/flash_master.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

$_ =~ s/\s//g;
$_ =~ s/\.00/0.00/g;
$_ = $_."\n";

####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table flash_master
go
exit
EOF
bcp cmf_data..flash_master in /tmp/flash_master.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"||" -r"||\n" -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating flash_master\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting rsaltlnk bcp*****\n";

open (BCPFILE,">/tmp/rsaltlnk.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/rsaltlnk.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\0//g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";


####################################################
print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table rsaltlnk
go
exit
EOF
bcp cmf_data..rsaltlnk in /tmp/rsaltlnk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/rsaltlnk.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating rsaltlnk\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

if (1==2){ #start of don't run
#**********************************************************************************************
print "****Starting rateschd bcp*****\n";

open (BCPFILE,">/tmp/rateschd.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/rateschd.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

# Modify date to sybase acceptable date
   $_ =~ s/(^...........)(..)(..)/$1\/$2\/$3/;

# Modify second date...
   $_ =~ s/(^.................................................................................)(..)(..)/$1\/$2\/$3/;


# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /g;
}
while (/(\/)(.\D)(\/)/){
# More bad data to be removed
   $_ =~ s/(^.+)(\/)(.\D)(\/)(..)/$1          /g;
#   print "$_\n";
}
   $_ =~ s/(^.+)(\/)(..)(\/)(\s.)/$1          /g;

   $_ =~ s/\s\.00/0.00/g;


# Skip if no tynumb
   next if (/^\s\s/);

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table rateschd
go
exit
EOF
bcp cmf_data..rateschd in /tmp/rateschd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/rateschd.fmt -m0 -b1 -Q
`;

print "Messages from truncating and repopulating rateschd\n\n$sqlError\n\n";
#**********************************************************************************************

}#eof don't run

#**********************************************************************************************
print "****Starting ara_mstr bcp*****\n";

open (BCPFILE,">/tmp/ara_mstr.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ara_mstr.txt") || print "cannot open: $!\n";

while (<INFILE>){
#last;

####################################################
$_ =~ s/(^.{21})(..)/$1\/$2\//;
$_ =~ s/(^.{34})(..)/$1\/$2\//;
$_ =~ s/(^.{45})(..)/$1\/$2\//;
$_ =~ s/(^.{55})(..)/$1\/$2\//;


# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
   $_ =~ s/(\/)(\D\D)(\/)(..)/ $2   /g;
}

$_ =~ s/(^.{30})(10)/$1.'20'/e;
$_ =~ s/(^.{51})(\d\.\d\d)/$1.'    '/e;
$_ =~ s/(^.{138})(\.)/$1.' '/e;

next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table ara_mstr
go
exit
EOF
bcp cmf_data..ara_mstr in /tmp/ara_mstr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ara_mstr.fmt -Q -m0 -b1000
`;


print "Messages from truncating and repopulating ara_mstr\n\n$sqlError\n\n";
#**********************************************************************************************

if(1==2){ #start of don't run

#**********************************************************************************************
print "****Starting cmfextra2 bcp*****\n";

open (BCPFILE,">/tmp/cmfextra2.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/asa/CMFEXTRA2.TXT") || print "cannot open: $!\n";

while (<INFILE>){

#   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

#Modify date variable
$_ =~ s/(^.{198})(..)/$1\/$2\//;

# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
   $_ =~ s/(\/)(\D\D)(\/)(..)/ $2   /g;
}

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmfextra2
#go
#exit
#EOF
#bcp cmf_data..cmfextra2 in /tmp/cmfextra2.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfextra2.fmt -m0 -b100 -Q
#`;

print "Messages from truncating and repopulating cmfextra2\n\n$sqlError\n\n";
#**********************************************************************************************

} #eof dont run

##**********************************************************************************************
#print "****Starting costing_residential bcp*****\n";
#
#open (BCPFILE,">/tmp/costing_residential.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/cmf_data/asa/COSTING_RESI.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
#
##   $_ =~ s/^\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r$//;
#   $_ =~ s/\n$//;
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;
#   $_ = $_."\n";
#
#####################################################
#
#print BCPFILE $_;
#
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table costing_residential
#go
#exit
#EOF
#bcp cmf_data..costing_residential in /tmp/costing_residential.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/costing_residential.fmt -m0 -b100 -Q
#`;
#
#print "Messages from truncating and repopulating costing_residential\n\n$sqlError\n\n";
##**********************************************************************************************

##**********************************************************************************************
#print "****Starting costing_import_list bcp*****\n";
#
#open (BCPFILE,">/tmp/costing_import_list.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/cmf_data/asa/COSTING_IMP_LIST.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
#
##   $_ =~ s/^\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r$//;
#   $_ =~ s/\n$//;
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;
#   $_ = $_."\n";
#
#####################################################
#
#print BCPFILE $_;
#
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table costing_import_list
#go
#exit
#EOF
#bcp cmf_data..costing_import_list in /tmp/costing_import_list.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/costing_import_list.fmt -m0 -b100 -Q
#`;
#
#print "Messages from truncating and repopulating costing_import_list\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting qmaparms bcp*****\n";

open (BCPFILE,">/tmp/qmaparms.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/qmaparms.txt") || print "cannot open: $!\n";

while (<INFILE>){

   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table qmaparms
go
exit
EOF
bcp cmf_data..qmaparms in /tmp/qmaparms.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/qmaparms.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating qmaparms\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting quotater and qt_period bcp*****\n";

open (BCPFILE1,">/tmp/quotater.dat") || print "cannot create $!\n";
open (BCPFILE2,">/tmp/qt_period.dat") || print "cannot create $!\n";

open (INFILE,"</opt/sybase/cmf_data/quotater.txt") || print "cannot open: $!\n";

while (<INFILE>){

   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################

$quotater = substr($_,0,47);
# Taking out the obsolete field that is no longer used, but exists in the pervasive file
$quotater_part1 = substr($_,0,12);
$quotater_part2 = substr($_,17,30);

# Regrouping the record with all valid fields
$quotater = $quotater_part1.$quotater_part2."\n";
$all_qt_periods = substr($_,48,length($_));

print BCPFILE1 $quotater;

for ($i=1;$i<14;$i++){

$qt_period = substr($all_qt_periods,(42*($i-1)),41);
$qt_period = substr($quotater,0,4).sprintf('%02d',($i)).sprintf('%04d',((localtime())[5]+1900)).$qt_period."\n";

print BCPFILE2 $qt_period;

} #eof for loop

}#eof while loop

close BCPFILE1;
close BCPFILE2;
close INFILE;

#Truncating tables
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table qt_period
go
exit
EOF
#bcp cmf_data..quotater in /tmp/quotater.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/quotater.fmt -m0 -b100 -Q
bcp cmf_data..qt_period in /tmp/qt_period.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/qt_period.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating quotater\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
#print "****Starting interline_costs bcp*****\n";
#
#open (BCPFILE,">/tmp/interline_costs.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/cmf_data/IL_COSTS.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
##last;
##   $_ =~ s/^\d\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r$//;
#   $_ =~ s/\n$//;
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;
#   $_ = $_."\n";
#
#
#####################################################
#
#print BCPFILE $_;
#
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table interline_costs
#go
#exit
#EOF
#bcp cmf_data..interline_costs in /tmp/interline_costs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/interline_costs.fmt -m0 -b100 -Q
#`;
#
#print "Messages from truncating and repopulating interline_costs\n\n$sqlError\n\n";
#**********************************************************************************

if (1==2) {
#**********************************************************************************************
print "****Starting misc_charges_hist bcp*****\n";

open (BCPFILE,">/tmp/misc_charges_hist.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/MISC_CHRG_HIST.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
#   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

   $_ =~ s/(^.{26})(..)/$1\/$2\//;
   $_ =~ s/(^.{85})(..)/$1\/$2\//;
   $_ =~ s/(^.{95})(..)/$1\/$2\//;
   $_ =~ s/(^.{105})(..)/$1\/$2\//;

# Remove empty dates slashes
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)(..)/ $2   /g;
}

 next if ($_ !~ /^\d\d\d\d\d\d\d\d/);
   if (/(^.{22})(....)(.)(..)(.)(..)/){
      if($2 > 2007 || $2 < 1995){
         if ($4 !~ /\d\d/){
            $_ =~ s/(^.{22})(....)(.)(..)(.)(..)/$1.'    '.'      '/e; 
         }else{
            $_ =~ s/(^.{22})(....)/$1.'2000'.$3.$4/e;
         }
      }
   }
####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table misc_charges_hist
go
exit
EOF
bcp cmf_data..misc_charges_hist in /tmp/misc_charges_hist.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/misc_charges_hist.fmt -m1000 -b1 -Q
`;

print "Messages from truncating and repopulating misc_charges_hist\n\n$sqlError\n\n";
#**********************************************************************************************

} # eof
#**********************************************************************************************
print "****Starting ZWDISCG bcp*****\n";

open (BCPFILE,">/tmp/ZWDISCG.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/ZWDISCG.TXT") || print "cannot open: $!\n";

while (<INFILE>){

#   $_ =~ s/^\d\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table ZWDISCG
#go
#exit
#EOF
#bcp cmf_data..ZWDISCG in /tmp/ZWDISCG.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/ZWDISCG.fmt -m0 -b1000 -Q
#`;

print "Messages from truncating and repopulating ZWDISCG\n\n$sqlError\n\n";

#**********************************************************************************************

if(1==2){ #start of don't run

#**********************************************************************************************
print "****Starting cmfstore bcp*****\n";

open (BCPFILE,">/tmp/cmfstore.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFSTORE.TXT") || print "cannot open: $!\n";

while (<INFILE>){

#   $_ =~ s/^\d\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ = $_."\n";

####################################################

print BCPFILE $_;

}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmfstore
#go
#exit
#EOF
#bcp cmf_data..cmfstore in /tmp/cmfstore.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmfstore.fmt -m0 -b1000 -Q
#`;

print "Messages from truncating and repopulating cmfstore\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting cmforgnl bcp*****\n";

open (BCPFILE,">/tmp/cmforgnl.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFORGNL.TXT") || print "cannot open: $!\n";

$firstRow = 0;
@rowArray = ();
while (<INFILE>){

   if(/^\d\d\d\d\d\d\d\d/){
      #$_ =~ ////\//g;
      if($firstRow == 1){
         push(@rowArray,"||||");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }

         $rowToAdd =~ s/\|\:\:/\r/g;
         $rowToAdd =~ s/\|\:\|/\n/g;
         $rowToAdd =~ s/\n\|\|\|\|$/\|\|\|\|/g; # Remove the last, as we are inserting a new one
         $rowToAdd =~ s/\|\|\|\|/||\n/g;
#         $rowToAdd =~ s/\|\:/\r/g;

         if (length($rowToAdd) < 2500){
            #print "Length: ".length($rowToAdd)."\n";
            #print "Row: $rowToAdd \n";
            $rowToAdd =~ s/\|\|$//;
            #print "Row: $rowToAdd \n";
         }

         print BCPFILE $rowToAdd;
         undef $rowToAdd;
         undef @rowArray;
         #@rowArray = ();
         #print "Length of the array now: $#rowArray\n";
      }
   $firstRow = 1;
   $_ =~ s/\0/ /g;
   $_ =~ s/\r/|::/g;
   $_ =~ s/\n/|:|/g;
#   $_ =~ s/\015/|:/g;
#   if (/\015/){ print "Found one: $_\n";}

   #$_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row
   #Modify date variable
   #Fix StartDate
   $_ =~ s/(^.{467})(..)/$1\/$2\//;
   #Fix LastModifiedDate
   $_ =~ s/(^.{492})(..)/$1\/$2\//;
   #FIx LastModifiedTime
   $_ =~ s/(^.{498})/$1 /;
   #Fix PAPPSStartDate
   $_ =~ s/(^.{734})(..)/$1\/$2\//;
   #Fix RateRenewalDate
   $_ =~ s/(^.{967})(..)/$1\/$2\//;

   # Remove empty dates slashes
   while (/(^.{467})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{467})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{492})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{492})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{498})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{498})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{734})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{734})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{967})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{967})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }


   push(@rowArray,$_);
   next;
   }else{
   #print  substr($_,0,8).":".substr($_,8,1)."\n";
      if($firstRow == 0){next;}
      $_ =~ s/\0/ /g;
      $_ =~ s/\r/|::/g;
      $_ =~ s/\n/|:|/g;
#      $_ =~ s/\015/|:/g;
#   if (/\015/){ print "Found one: $_\n";}

      push(@rowArray,$_);
      next;
   }

}#eof of while loop

# Insert the last line into the file as well

 if($firstRow == 1){
         push(@rowArray,"||||");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }
         $rowToAdd =~ s/\|\:\:/\r/g;
         $rowToAdd =~ s/\|\:\|/\n/g;
         $rowToAdd =~ s/\n\|\|\|\|$/||||/g; # Remove the last, as we are inserting a new one
         $rowToAdd =~ s/\|\|\|\|/||\n/g;
#         $rowToAdd =~ s/\|\:/\r/g;

         print BCPFILE $rowToAdd;
         undef $rowToAdd;
         undef @rowArray;
      }


close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmforgnl
#go
#exit
#EOF
#bcp cmf_data..cmforgnl in /tmp/cmforgnl.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmforgnl.fmt -m2 -b1 -Q -e./errfile
#`;

print "Messages from truncating and repopulating cmforgnl\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting cmnnotes bcp***********************#
print "*****Starting cmnnotes bcp******\n";
open (BCPFILE,">/tmp/cmnnotes.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNNOTES.TXT") || print "cannot open: $!\n";

$firstRow = 0;
@rowArray = ();
while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d\d,//;
   if(/^\d\d\d\d\d\d\d\d\w\w/){
      if($firstRow == 1){
         push(@rowArray,"||\n");
         foreach $line (@rowArray){
            $rowToAdd .= $line;
         }
         print BCPFILE $rowToAdd;
         undef $rowToAdd;
         undef @rowArray;
         #@rowArray = ();
         #print "Length of the array now: $#rowArray\n";
      }
   $firstRow = 1;
   $_ =~ s/\0/ /g;
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   #$_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row
   $_ =~ s/(.............................)(..)(..)(.)/$1\/$2\/$3 $4/;
   if (/(\/)(\D\D)(\/)/){
      $_ =~ s/(\/)(\D\D)(\/)/ $2 /;
   }
   push(@rowArray,$_);
   next;
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


#Truncating table 
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#drop index cmnnotes.cmnnotes_idx_1
#go
#truncate table cmnnotes
#go
#exit
#EOF
#bcp cmf_data..cmnnotes in /tmp/cmnnotes.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnnotes.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnnotes) > 1)
#CREATE INDEX cmnnotes_idx_1
#ON cmnnotes(customer_num,note_group,note_date_time)
#else
#select "No data in table: cmnnotes"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnnotes\n\n$sqlError\n\n";
#****************************************************************************#
#die;
#} #eof dont run

#**************************Starting cmnprice bcp***********************#
print "******Starting cmnprice bcp******\n";
open (BCPFILE,">/tmp/cmnprice.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNPRICE.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g;
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   print BCPFILE $_;
}#eof of while loop
close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnprice drop constraint cmnprice_pkey
#go
#truncate table cmnprice
#go
#exit
#EOF
#bcp cmf_data..cmnprice in /tmp/cmnprice.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnprice.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnprice) > 1)
#ALTER TABLE cmnprice
#ADD CONSTRAINT cmnprice_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmnprice"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnprice\n\n$sqlError\n\n";
#die;
#} #eof of dont run

#**************************Starting cmnrates bcp***********************#
print "*****Starting cmnrates bcp******\n";
open (BCPFILE,">/tmp/cmnrates.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNRATES.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   if (/(........................)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(........................)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }
   if ($found1 eq "1"){
      ##print "found1 is 1\n";
      if (/(.*.)(\/..\/..)(....................................................................................................................................................................................................)(..)(..)/){
            #print "I have the second date\n";
            $found2 = "1";
            $_ =~ s/(.*.)(\/..\/..)(....................................................................................................................................................................................................)(..)(..)/$1$2$3\/$4\/$5/;
            #print $_;
      }
   }
   if ($found2 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.........)(..)(..)/){
            #print "I have the third date\n";
            $found3 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.........)(..)(..)/$1$2$3$4\/$5\/$6/;
            #print $_;
      }
   }
   if ($found3 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.............................................................)(..)(..)/){
            #print "I have the forth date\n";
            $found4 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.............................................................)(..)(..)/$1$2$3$4$5$6\/$7\/$8/;
            #print $_;
      }
   }

####################################################
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /;
#   print "$_\n";
}

next if (/^0\s/);
#print "after removing bad dates\n";
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnrates drop constraint web_cmnrates_pkey
#go
#truncate table cmnrates
#go
#exit
#EOF
#bcp cmf_data..cmnrates in /tmp/cmnrates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnrates.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnrates) > 1)
#ALTER TABLE cmnrates
#ADD CONSTRAINT web_cmnrates_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmnrates"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnrates\n\n$sqlError\n\n";
#**********************************************************************#
#die;
#} #eof dont run

#**************************Starting cmnservc bcp***********************#
print "*****Starting cmnservc bcp******\n";
open (BCPFILE,">/tmp/cmnservc.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNSERVC.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   if (/(.......................................)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(.......................................)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }
   if ($found1 eq "1"){
      ##print "found1 is 1\n";
      if (/(.*.)(\/..\/..)(..............................................................................................................................................................................................................................................................................)(..)(..)/){
            #print "I have the second date\n";
            $found2 = "1";
            $_ =~ s/(.*.)(\/..\/..)(..............................................................................................................................................................................................................................................................................)(..)(..)/$1$2$3\/$4\/$5/;
            #print $_;
      }
   }
   if ($found2 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/){
            #print "I have the third date\n";
            $found3 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/$1$2$3$4\/$5\/$6/;
            #print $_;
      }
   }
   if ($found3 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(...............................)(..)(..)/){
            #print "I have the forth date\n";
            $found4 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(...............................)(..)(..)/$1$2$3$4$5$6\/$7\/$8/;
            #print $_;
      }
   }
   if ($found4 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/){
            #print "I have the fifth date\n";
            $found5 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/$1$2$3$4$5$6$7$8\/$9\/$10/;
            #print $_;
      }
   }

####################################################
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /;
#   print "$_\n";
}
#print "after removing bad dates\n";
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;


#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnservc drop constraint cmnservc_pkey
#go
#truncate table cmnservc
#go
#exit
#EOF
#bcp cmf_data..cmnservc in /tmp/cmnservc.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnservc.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnservc) > 1)
#ALTER TABLE cmnservc
#ADD CONSTRAINT cmnservc_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmnservc"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnservc\n\n$sqlError\n\n";
#die;

#**********************************************************************#
#}#eof dont run

#**************************Starting cmnshipr bcp***********************#
print "*****Starting cmnshipr bcp*****\n";
open (BCPFILE,">/tmp/cmnshipr.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNSHIPR.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

   if (/(.......................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................)(..)(..)/){
      $found1 = "1";
   $_ =~ s/(.......................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................)(..)(..)/$1\/$2\/$3/;
      #print $_;
   }
   if ($found1 eq "1"){
      ##print "found1 is 1\n";
      if (/(.*.)(\/..\/..)(...................)(..)(..)(.)/){
            #print "I have the second date\n";
            $found2 = "1";
            $_ =~ s/(.*.)(\/..\/..)(...................)(..)(..)(.)/$1$2$3\/$4\/$5 $6/;
            #print $_;
      }
   }
   if ($found2 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/...........)(....)(..)(..)/){
            #print "I have the third date\n";
            $found3 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/...........)(....)(..)(..)/$1$2$3$4\/$5\/$6/;
            #print $_;
      }
   }
   if ($found3 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/){
            #print "I have the forth date\n";
            $found4 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/$1$2$3$4$5$6\/$7\/$8/;
            #print $_;
      }
   }
   if ($found4 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/){
            #print "I have the fifth date\n";
            $found5 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/$1$2$3$4$5$6$7$8\/$9\/$10/;
            #print $_;
      }
   }
   if ($found5 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/){
            #print "I have the sixth date\n";
            $found6 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/$1$2$3$4$5$6$7$8$9$10\/$11\/$12/;
            #print $_;
      }
   }
   if ($found6 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/){
            #print "I have the sixth date\n";
            $found7 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(....)(..)(..)/$1$2$3$4$5$6$7$8$9$10\/$11\/$12/;
            #print $_;
      }
   }
   if ($found7 eq "1"){
      if (/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(...................................)(..)(..)/){
            #print "I have the seventh date\n";
            $found8 = "1";
            $_ =~ s/(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(.*.)(\/..\/..)(...................................)(..)(..)/$1$2$3$4$5$6$7$8$9$10$11$12\/$13\/$14/;
            #print $_;
      }
   }

####################################################
while (/(\/)(\D\D)(\/)/){
#   print "Found a bad date: $1$2$3\n";
   if(/(\d\d\D\D)(\/)(\D\D)(\/)/){
      $_ =~ s/(\d\d\D\D)(\/)(\D\D)(\/)/     $3 /;
      next;
   }
   if(/1900\/00\/00/){
      $_ =~ s/1900\/00\/00/          /;
      next;
   }
   $_ =~ s/(\/)(\D\D)(\/)/ $2 /g;
#   print "$_\n";
}

$_ =~ s/(^.{815})(.....)(\D\D)(...)/$1          /;

#print "after removing bad dates\n";
next if(/^\s\s/);
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnshipr drop constraint web_cmnshipr_pkey
#go
#truncate table cmnshipr
#go
#exit
#EOF
#bcp cmf_data..cmnshipr in /tmp/cmnshipr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnshipr.fmt -m0 -b1 -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnshipr) > 1)
#ALTER TABLE cmnshipr
#ADD CONSTRAINT web_cmnshipr_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmnshipr"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnshipr\n\n$sqlError\n\n";
#die;

#**************************Starting cmnbilto bcp***********************#
print "****Starting cmnbilto bcp*****\n";

open (BCPFILE,">/tmp/cmnbilto.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNBILTO.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnbilto drop constraint cmnbilto_pkey
#go
#truncate table cmnbilto
#go
#exit
#EOF
#bcp cmf_data..cmnbilto in /tmp/cmnbilto.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnbilto.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnbilto) > 1)
#ALTER TABLE cmnbilto
#ADD CONSTRAINT cmnbilto_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmnbilto"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnbilto\n\n$sqlError\n\n";
#die;

#**************************Starting cmnsales bcp***********************#
print "******Starting cmnsales bcp*******\n";

open (BCPFILE,">/tmp/cmnsales.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNSALES.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnsales drop constraint cmnsales_pkey
#go
#truncate table cmnsales
#go
#exit
#EOF
#bcp cmf_data..cmnsales in /tmp/cmnsales.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnsales.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnsales) > 1)
#ALTER TABLE cmnsales
#ADD CONSTRAINT cmnsales_pkey
#PRIMARY KEY NONCLUSTERED (customer_num)
#else
#select "No data in table: cmnsales"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnsales\n\n$sqlError\n\n";
#die;

#}# eof of dont run

#**************************Starting cmnndata bcp***********************#
print "******Starting cmnndata bcp*******\n";

open (BCPFILE,">/tmp/cmnndata.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMNNDATA.TXT") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/^\d\d,//;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r//g;
   $_ =~ s/\n//g;
   $_ = $_."\n"; #remove all carraige returns and new line char and add one add the end of the row

####################################################
next if(/^\s\s/); #Don't write if it is an empty line
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#alter table cmnndata drop constraint cmnndata_pkey

#go
#truncate table cmnndata
#go
#exit
#EOF
#bcp cmf_data..cmnndata in /tmp/cmnndata.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmnndata.fmt -Q
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#if((select count(*) from cmnndata) > 1)
#ALTER TABLE cmnndata
#ADD CONSTRAINT cmnndata_pkey
#PRIMARY KEY NONCLUSTERED (customer)
#else
#select "No data in table: cmnndata"
#go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmnndata\n\n$sqlError\n\n";
#die;
#}# eof of dont run

#**********************************************************************************************
print "****Starting cmf_rates_org bcp*****\n";

open (BCPFILE,">/tmp/cmf_rates_org.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFRATESORG.TXT") || print "cannot open: $!\n";

while (<INFILE>){

   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;

   #Modify date variable
   #Fix Effective_Date
   $_ =~ s/(^.{12})(..)/$1\/$2\//;
   #Fix Rate_Renewal_Date
   $_ =~ s/(^.{47})(..)/$1\/$2\//;
   #Fix GRD_zw_effective
   $_ =~ s/(^.{121})(..)/$1\/$2\//;
   #Fix SEL_zw_effective
   $_ =~ s/(^.{142})(..)/$1\/$2\//;
   #Fix USA_zw_effective
   $_ =~ s/(^.{164})(..)/$1\/$2\//;
   #Fix PUT_zw_effective
   $_ =~ s/(^.{182})(..)/$1\/$2\//;
   #Fix ALT_zw_effective
   $_ =~ s/(^.{200})(..)/$1\/$2\//;

   # Remove empty dates slashes
   while (/(^.{12})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{12})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{47})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{47})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{121})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{121})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{142})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{142})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{164})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{164})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{182})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{182})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{200})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{200})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   $_ =~ s/(^.{537})(.+$)/$1/;
   $_ =~ s/(^.{535})(.)(.)/$1$3 /;
   $_ = $_."  \n";

print BCPFILE $_;
}#eof of while loop

close BCPFILE;
close INFILE;

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
truncate table cmf_rates_org
go
--alter table cmf_rates_org drop constraint cmf_rates_org_pkey
--go
exit
EOF
bcp cmf_data..cmf_rates_org in /tmp/cmf_rates_org.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_rates_org.fmt -m2 -b1 -Q -e./errfile
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
--ALTER TABLE dbo.cmf_rates_org
--ADD CONSTRAINT cmf_rates_org_pkey
--PRIMARY KEY NONCLUSTERED (customer_num)
--go
exit
EOF
`;

print "Messages from truncating and repopulating cmf_rates_org\n\n$sqlError\n\n";
#**********************************************************************************************

#} #eof dont run
#**********************************************************************************************
print "****Starting cmf_rates_new bcp*****\n";

open (BCPFILE,">/tmp/cmf_rates_new.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFRATESNEW.TXT") || print "cannot open: $!\n";

while (<INFILE>){

   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;

   #Modify date variable
   #Fix Effective_Date
   $_ =~ s/(^.{12})(..)/$1\/$2\//;
   #Fix Rate_Renewal_Date
   $_ =~ s/(^.{47})(..)/$1\/$2\//;
   #Fix GRD_zw_effective
   $_ =~ s/(^.{121})(..)/$1\/$2\//;
   #Fix SEL_zw_effective
   $_ =~ s/(^.{142})(..)/$1\/$2\//;
   #Fix USA_zw_effective
   $_ =~ s/(^.{164})(..)/$1\/$2\//;
   #Fix PUT_zw_effective
   $_ =~ s/(^.{182})(..)/$1\/$2\//;
   #Fix ALT_zw_effective
   $_ =~ s/(^.{200})(..)/$1\/$2\//;

   # Remove empty dates slashes
   while (/(^.{12})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{12})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{47})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{47})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{121})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{121})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{142})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{142})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{164})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{164})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{182})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{182})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{200})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{200})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   $_ =~ s/(^.{537})(.+$)/$1/;
   $_ =~ s/(^.{535})(.)(.)/$1$3 /;
   $_ = $_."  \n";

print BCPFILE $_;
}#eof of while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmf_rates_new
#go
#--alter table cmf_rates_new drop constraint cmf_rates_new_pkey
#--go
#exit
#EOF
#bcp cmf_data..cmf_rates_new in /tmp/cmf_rates_new.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_rates_new.fmt -m2 -b1 -Q -e./errfile
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#--ALTER TABLE dbo.cmf_rates_new
#--ADD CONSTRAINT cmf_rates_new_pkey
#--PRIMARY KEY NONCLUSTERED (customer_num)
#--go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmf_rates_new\n\n$sqlError\n\n";
#**********************************************************************************************
#die;

#**********************************************************************************************
print "****Starting cmf_rates_old bcp*****\n";

open (BCPFILE,">/tmp/cmf_rates_old.dat") || print "cannot create $!\n";
open (INFILE,"</opt/sybase/cmf_data/CMFRATESOLD.TXT") || print "cannot open: $!\n";

while (<INFILE>){

   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r$//;
   $_ =~ s/\n$//;
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;

   #Modify date variable
   #Fix Effective_Date
   $_ =~ s/(^.{12})(..)/$1\/$2\//;
   #Fix Rate_Renewal_Date
   $_ =~ s/(^.{47})(..)/$1\/$2\//;
   #Fix GRD_zw_effective
   $_ =~ s/(^.{121})(..)/$1\/$2\//;
   #Fix SEL_zw_effective
   $_ =~ s/(^.{142})(..)/$1\/$2\//;
   #Fix USA_zw_effective
   $_ =~ s/(^.{164})(..)/$1\/$2\//;
   #Fix PUT_zw_effective
   $_ =~ s/(^.{182})(..)/$1\/$2\//;
   #Fix ALT_zw_effective
   $_ =~ s/(^.{200})(..)/$1\/$2\//;

   # Remove empty dates slashes
   while (/(^.{12})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{12})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{47})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{47})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{121})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{121})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{142})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{142})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{164})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{164})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{182})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{182})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   # Remove empty dates slashes
   while (/(^.{200})(\/)(\D\D)(\/)/){
      $_ =~ s/(^.{200})(\/)(\D\D)(\/)(..)/$1 $3   /;
   }

   $_ =~ s/(^.{537})(.+$)/$1/;
   $_ =~ s/(^.{535})(.)(.)/$1$3 /;
   $_ = $_."  \n";

print BCPFILE $_;
}#eof of while loop

close BCPFILE;
close INFILE;

#Truncating table
#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#truncate table cmf_rates_old
#go
#--alter table cmf_rates_old drop constraint cmf_rates_old_pkey
#--go
#exit
#EOF
#bcp cmf_data..cmf_rates_old in /tmp/cmf_rates_old.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -f/opt/sybase/bcp_data/cmf_data/cmf_rates_old.fmt -m2 -b1 -Q -e./errfile
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
#use cmf_data
#go
#--ALTER TABLE dbo.cmf_rates_old
#--ADD CONSTRAINT cmf_rates_old_pkey
#--PRIMARY KEY NONCLUSTERED (customer_num)
#--go
#exit
#EOF
#`;

print "Messages from truncating and repopulating cmf_rates_old\n\n$sqlError\n\n";
#**********************************************************************************************
} #eof dont run

print "\n\ncmf_data conversion and load to cmf_data completed...".localtime()."\n\n";

#**********************************************************************************************
# Running IQ load now...
print "Running IQ load now...".localtime()."\n";

$sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/load_cmf_data.pl $prodserver > /opt/sybase/cron_scripts/cron_logs/load_cmf_data.log 2>\&1'`;

print "Any errors from the IQ load...".localtime()."\n$sshIQError\n\n";

#**********************************************************************************************

print "Running UpdateAC procedure now...".localtime()."\n\n";
$updateAC = `/opt/sybase/cron_scripts/UpdateAC.pl > /opt/sybase/cron_scripts/cron_logs/UpdateAC.log 2>\&1 \&
`;

print "Any errors in UpdateAC...".localtime()."\n$updateAC\n\n";

#********************************************
# Wait until 5AM for dump and load
# For night jobs to complete
#*******************************************
#$hour=sprintf('%02d',((localtime())[2]));
#$hour = int($hour);
#$day=sprintf('%02d',((localtime())[6]));
#$day= int($day);
#
#print "Hour: $hour\n";
#
#while ($hour != 5 && $day != 0){
#sleep(1200);
#$hour=sprintf('%02d',((localtime())[2]));
#$hour = int($hour);
#print "Waiting for 5AM to start the dump and load routine: $hour\n";
#}


########################################################################
#Start replication setup on 0 or 30th minute so that it won't kick off a page...
$startMin=sprintf('%02d',((localtime())[1]));
$Min = int($startMin);

if ($Min > 30){
$sleep_for = (59 - $Min + 1); #Minutes
sleep($sleep_for*60);
}else{
$sleep_for = (30 - $Min); #Minutes
sleep($sleep_for*60);
}

#***************Recreating Standby connection************
#$createError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Ssybrep1 -w300 <<EOF 2>&1
#create connection to $standbyserver.cmf_data
#set error class to rs_sqlserver_error_class
#set function string class to rs_sqlserver_function_class
#set username to cmf_data_maint
#set password to sybase
#set db_packet_size to '1024'
#with log transfer on
#as standby for LDS.cmf_data
#use dump marker
#go
#exit
#EOF
#`;

$createError .= ": ".localtime();

print "***********Replication Create Connection Error************\n\n$createError\n";
   if($createError =~ /Msg/){
      print "Errors may occurred during rep connection of cmf_data...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - Create Standby Connection Failed: cmf_data

$createError
EOF
`;
   }


print "\n\nStarting Dump and Load of cmf_data\n\n";

$dumpError = `/opt/sybase/cron_scripts/dump_db.pl cmf_data dumponly> /opt/sybase/cron_scripts/cron_logs/cmf_data.dumpdb.log 2>\&1`;
print "\n\n$dumpError\n\n";

$currTime = localtime();


print "CMF LOAD HAS COMPLETED SUCCESSFULLY!!".localtime()."\n";
