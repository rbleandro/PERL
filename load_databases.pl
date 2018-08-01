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

$prodserver = $ARGV[0];

print "Server Being Loaded: $prodserver\n";

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep load_databases.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_databases.pl"|grep -v "less load_databases.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
load database shippingws from "/opt/sap/db_backups/shippingws.dmp" 
go
online database shippingws
go
load database canshipws from "/opt/sap/db_backups/canshipws.dmp" 
go
online database canshipws
go
load database uss from "/opt/sap/db_backups/uss.dmp" 
go
online database uss
go
load database termexp from "/opt/sap/db_backups/termexp.dmp" 
go
online database termexp
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - load_databases at $finTime

$sqlError
EOF
`;
die;
}else{
$finTime = localtime();
print "Time Finished: $finTime\n";
}
