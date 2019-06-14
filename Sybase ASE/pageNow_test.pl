#!/usr/bin/perl -w

#Script:   This script sends out pages when thresholds of segments in database
#          are reached. This script is executed from within threshold stored
#          procedure and should not be used individually.
#
#Author:   Amer Khan
#Revision:
#Date           Name            Description
#---------------------------------------------------------------------------------
#08/27/04       Amer Khan       Originally created
#Mar 30 2019	Rafael Bahia	Changed the script to automatically add extra space as a precaution
#Apr 03 2019	Rafael Bahia	Implemented better error handling and mail messaging


#Usage Restrictions
if ($#ARGV != 2){
print "Usage: pageNow.pl cpscan image_seg 256000 \n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR on script pageNow.pl. Check as soon as possible!!

The script didn't receive the proper parameters in the right order. Check the threshold procedures on Sybase and match the parameters. The script is located is /opt/sap/cron_scripts/pageNow.pl.
EOF
`;
}

use Sys::Hostname;
$prodserver = hostname();

if ($prodserver =~ /cpsybtest2/){
$prodserver='CPSYBTEST';
}

#open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
#while (<PROD>){
#@prodline = split(/\t/, $_);
#$prodline[1] =~ s/\n//g;
#}
#if ($prodline[1] eq "0" ){
#print "standby server \n";
#die "This is a stand by server\n";
#}

#Saving argument
$dbname = $ARGV[0];
$segname = $ARGV[1];
$space_left = $ARGV[2];

if ($segname eq "logsegment"){
$spacetoadd = 1000;
}else{
$spacetoadd = 5000;
}

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1]-1)); #Subtract one to check the past minute

#Convert to MB
$space_left = ($space_left/512);

print $space_left;
print $segname;
print $spacetoadd;
