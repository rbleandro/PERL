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
exec master.dbo.rp_kill_db_processes 'shippingws'
go
declare \@count tinyint
declare \@dbname varchar(100)
set \@dbname='shippingws'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
while \@count>0
begin
waitfor delay '00:05:00'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
end
load database shippingws from "/opt/sap/db_backups/shippingws.dmp" 
go
online database shippingws
go
exec master.dbo.rp_kill_db_processes 'canshipws'
go
declare \@count tinyint
declare \@dbname varchar(100)
set \@dbname='canshipws'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
while \@count>0
begin
waitfor delay '00:05:00'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
end
load database canshipws from "/opt/sap/db_backups/canshipws.dmp" 
go
online database canshipws
go
exec master.dbo.rp_kill_db_processes 'uss'
go
declare \@count tinyint
declare \@dbname varchar(100)
set \@dbname='uss'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
while \@count>0
begin
waitfor delay '00:05:00'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
end
load database uss from "/opt/sap/db_backups/uss.dmp" 
go
online database uss
go
exec master.dbo.rp_kill_db_processes 'termexp'
go
declare \@count tinyint
declare \@dbname varchar(100)
set \@dbname='termexp'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
while \@count>0
begin
waitfor delay '00:05:00'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
end
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
