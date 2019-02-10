#!/usr/bin/perl 

###################################################################################
#Script:   This script monitors cmf_data load from pervasive and reports if       #
#          does not complete in time.                                             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#May 15,07	Amer Khan       Originally created                                #
#                                                                                 #
#                                                                                 #
###################################################################################

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
$prodserver = hostname();

#Setting Time
$currDate=localtime();

#Check if the load cmf_data is still running
undef $isProcessRunning;
#$isProcessRunning =`ps -ef|grep sybase|grep perl|grep load_cmf_data.pl`;
$isProcessRunning =`ps -ef|grep -v sh|grep sybase|grep load_cmf_data.pl`;

print "\nProcess is still running ".$isProcessRunning."\n";
die;


#Check if the process completed successfully
#$completed=`tail -10 /opt/sap/cron_scripts/cron_logs/load_cmf_data.log | grep COMPLETED`;
$completed=`grep "cmf_data conversion and load to cmf_data completed" /opt/sap/cron_scripts/cron_logs/load_cmf_data.log`;

if($isProcessRunning || !($completed)){
   print "\nProcess is still running ".$isProcessRunning."\n";

      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: CMF LOAD FROM PERVASIVE IS NOT COMPLETE!!!

Check it now!!!

Dated: $currDate
EOF
`;

#Something wrong, can't go any furher, must save the log file
die "Something wrong, can't go any furher, must save the log file";
}

#All is good -- removing the log file for next time around
$rmError = `mv /opt/sap/cron_scripts/cron_logs/load_cmf_data.log /opt/sap/cron_scripts/cron_logs/load_cmf_data.bk`;
#print "Any messages while moving the log file...$rmError\n";

