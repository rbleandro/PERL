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

$database = $ARGV[0];

$prodserver='CPSYBTEST';

print "Server Being Loaded: $prodserver\n";

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

#$my_pid = getppid();
#$isProcessRunning =`ps -ef|grep sybase|grep load_databases_mpr.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_databases_mpr.pl"|grep -v "less load_databases_mpr.pl"`;
#
##print "My pid: $my_pid\n";
#print "Running: $isProcessRunning \n";
#
#if ($isProcessRunning){
#die "\n Can not run, previous process is still running \n";
#
#}else{
#print "No Previous process is running, continuing\n";
#}
#
#print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Cleaning up the backup volume to free space (deletes all files older than 7 days)
$deleteoldfiles =`find /home/sybase/db_backups/ -mindepth 1 -mtime +7 -delete`;

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
exec rp_kill_db_processes '$database'
go
load database $database from "/home/sybase/db_backups/$database.dmp" 
go
online database $database
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - load_databases_to_test at $finTime

$sqlError
EOF
`;
die;
}else{
$finTime = localtime();
print "Time Finished: $finTime\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Success - load_databases_to_test for $database at $finTime

$sqlError
EOF
`;
}
