#!/usr/bin/perl -w

##############################################################################
#Script:   This script checks SVP URL delays                                 #
#                                                                            #
#Author:	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Oct 12 2016	Amer Khan	Created					     #
##############################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}

use Sys::Hostname;
$testserver = '10.3.1.165';

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$database = $ARGV[0];

#Copying files to TEST server
$scpError=`scp -p /home/sybase/db_backups/$database.dmp sybase\@$testserver:/home/sybase/db_backups`;
print "$scpError\n";


###############################
#Run load in TEST server now
###############################

#Loading databases into TEST server
$load_msgs = `ssh $testserver /opt/sap/cron_scripts/load_databases_to_test.pl $database`;

print "$load_msgs \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
