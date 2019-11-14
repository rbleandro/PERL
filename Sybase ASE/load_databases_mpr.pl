#!/usr/bin/perl -w

#Script:   	Script to load mpr_databases at the secondary servers
#
#Author:	Rafael Leandro
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#June 06 2018	Rafael Leandro	Created
#Aug 02 2019	Rafael Leandro	Changed the backup folder for CPDB2 to /opt/sap/db_backups after remounting it on Linux

$prodserver = $ARGV[0];

print "Server Being Loaded: $prodserver\n";

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep load_databases_mpr.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_databases_mpr.pl"|grep -v "less load_databases_mpr.pl"`;

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
load database mpr_data from "/opt/sap/db_backups/mpr_data.dmp"
go
online database mpr_data
go
load database mpr_data_lm from "/opt/sap/db_backups/mpr_data_lm.dmp"
go
online database mpr_data_lm
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - load_databases_mpr at $finTime

$sqlError
EOF
`;
die;
}else{
$finTime = localtime();
print "Time Finished: $finTime\n";
}
