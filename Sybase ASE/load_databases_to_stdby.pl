#!/usr/bin/perl -w

#Script:   	This script loads a database to the standby server on demand.
#Usage:		load_databases_to_stdby.pl <dbname(string)> [mailrecipient(string)] [resumeSRSconnection(bit)]
#Examples:	load_databases_to_stdby.pl dba rleandro 0
#Author:	Rafael Bahia
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#Jan 7  2019	Rafael Leandro	Created
#May 16 2019	Rafael Leandro	Added usage restrictions and an option to send the alerts to specific people only
#July 20 2019	Rafael Leandro	Added a parameter that allows connection to the replication server to resume any connections to the loaded database
#July 28 2019	Rafael Leandro	Added the keywords "terminated" and "disconnect" to the error check (in case the load session is killed)

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
use Sys::Hostname;
$prodserver = hostname();

$database = $ARGV[0];

my $dba = $ARGV[1];
if (defined $dba) {
    $mail=$dba;
} else {
    $mail='CANPARDatabaseAdministratorsStaffList';
} 

my $resumerep = $ARGV[2];
if (defined $resumerep) {
    $resumerep=$resumerep;
} else {
    $resumerep=0;
} 

print "Server Being Loaded: $prodserver\n";

#$my_pid = getppid();
#$isProcessRunning =`ps -ef|grep sybase|grep load_databases_to_stdby.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_databases_to_stdby.pl"|grep -v "less load_databases_to_stdby.pl"`;
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

#Cleaning up the backup volume to free space (deletes all files older than 7 days)
`find /opt/sap/db_backups/ -mindepth 1 -mtime +7 -delete`;

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
exec dbo.rp_kill_db_processes '$database'
go
load database $database from "/opt/sap/db_backups/$database.dmp" 
go
online database $database
go
use $database
go
dbcc settrunc(ltm,ignore)
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /terminated/ || $sqlError =~ /disconnect/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - load_databases_to_stdby at $finTime

$sqlError
EOF
`;
die;
}
else
{
	
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use $database
go
exec sp_dropuser $database\_maint
go
exec sp_dropalias $database\_maint
go
exec sp_addalias $database\_maint,'dbo'
go
exit
EOF
`;

print "$sqlError\n";

if ($resumerep == 1){
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -Shqvsybrep3 <<EOF 2>&1
resume connection to $prodserver.$database
go
exit
EOF
`;
}

$finTime = localtime();
print "Time Finished: $finTime\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Success - load_databases_to_stdby for $database at $finTime

$sqlError
EOF
`;
}
