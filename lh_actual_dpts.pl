#!/usr/bin/perl -w

##############################################################################
#Script:   This script created actual departs for linehaul.		     #
#                                                                            #
#Author:	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Aug 29 2017	Amer Khan	Created					     #
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
$prodserver = hostname();

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep lh_actual_dpts.pl|grep -v grep|grep -v $my_pid|grep -v "vim lh_actual_dpts.pl"|grep -v "less lh_actual_dpts.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use cpscan
go    
exec lh_actual_dpts
go 
exit
EOF
`;

if ($sqlError =~ /Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - lh_actual_dpts at $finTime

$sqlError
EOF
`;
}

print "Query Results: $sqlError \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
