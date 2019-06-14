#!/usr/bin/perl -w

#Script:   This script loads a database to the DR server
#
#Author:	Rafael Bahia
#Revision:
#Date           	Name            Description
#----------------------------------------------------------------------------
#Jan 7  2019		Rafael Bahia	Created
#May 16 2019		Rafael Bahia	Added usage restrictions

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "1" ){
	print "production server \n";
    die "This is the production server. Can't run this here.\n";
}

$database = $ARGV[0];

my $dba = $ARGV[1];
if (defined $dba) {
    $mail=$dba;
} else {
    $mail='CANPARDatabaseAdministratorsStaffList';
}

$prodserver='CPDB4';

print "Server Being Loaded: $prodserver\n";

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep load_databases_to_dr.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_databases_to_dr.pl"|grep -v "less load_databases_to_dr.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

#print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Cleaning up the backup volume to free space (deletes all files older than 7 days)
$deleteoldfiles =`find /opt/sap/db_backups/ -mindepth 1 -mtime +7 -delete`;

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
load database $database from "/opt/sap/db_backups/$database.dmp"
go
online database $database
go
use $database
go
sp_config_rep_agent $database, send_warm_standby_xacts,true
go
dbcc settrunc(ltm,ignore)
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - load_databases_to_dr at $finTime

$sqlError
EOF
`;
die;
}else{
$finTime = localtime();
print "Time Finished: $finTime\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Success - load_databases_to_dr for $database at $finTime

$sqlError
EOF
`;
}
