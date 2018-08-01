#!/usr/bin/perl -w

##############################################################################
#Description: This script runs the proc parcelwork procedures                #
#                                                                            #
#Author:    Amer Khan                                                        #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Jul 31 2008    Amer Khan       Originally created                           #
#                                                                            #
##############################################################################

#Usage Restrictions
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

#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));
$startMonth=sprintf('%02d',((localtime())[4]));
$startDay=sprintf('%02d',((localtime())[3]));
$startYear=sprintf('%02d',((localtime())[5]));

$startMonth += 1; #Month in perl starts from 0 and ends on 11.
$startYear += 1900; #Needed to get correct 4digit year.

while ($startHour ne '23' && $startHour ne '00' && $startHour ne '01' && $startHour ne '02' && $startHour ne '03' && $startHour eq '04'){
print "start hour: $startHour \n";
sleep(5);
}
print "It is time to run url: $startHour \n";
