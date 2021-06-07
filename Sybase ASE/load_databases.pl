#!/usr/bin/perl -w


#Script:   This script loads databases to the secondary servers
#
#Author:		Amer Khan
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#Oct 12 2016	Amer Khan		Created
#Aug 14 2019	Rafael Leandro	Since all user databases have been added to the replication, this script was completely rewritten to refect this and will now only do on-demand load operations.

###ATTENTION! THIS SCRIPT WAS DESIGNED TO WORK ALONG WITH PRODUCTION'S dump_databases.pl SCRIPT AND WILL NOT WORK ON ITS OWN.
###IF YOU NEED TO RUN ONLY THE LOAD OPERATION FOR A DATABASE, CHECK THE SCRIPTS load_databases_to_dr.pl and load_databases_to_stdby.pl.
###ALTERNATIVELY, YOU CAN RUN THE LOAD DATABASE SCRIPT GENERATED BY THE dump_databases.pl SCRIPT (CHECK THE SCRIPT'S OUTPUT OR LOG FOR MORE DETAILS).

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $allowparallel=0; #if 1 (one), allows multiple instances of the script to run in parallel
my $database=""; #database to backup/copy/load
my $cmd="";
my $help;

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'allowparallel|ap=i' => \$allowparallel,
	'to|r=s' => \$mail,
	'loadcommand|ld=s' => \$cmd,
	'dbname|d=s' => \$database
) or die "Usage: $0 --skipcheckprod 0 --to rleandro\n";

$help = "$0 usage:

--dbname or -d = Name of the database to be dumped. Mandatory.
--skipcheckprod or -s = Allows the script to run in non-production environment. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--to rleandro or -r = Mail recipient for any email alerts. Specify only the string before the @ sign. Optional. Default DBA group mail.
--allowparallel or -ap = if 1 (one), allows multiple instances of the script to run in parallel. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--loadcommand or -lc = Command to use when loading the database. Comes from the dump_database.pl script ran at the production server.\n\n";

if ($database eq "") {die "\nMsg: Database name cannot be blank.\n\n $help";}
if ($cmd eq "") {die "\nMsg: Load command cannot be blank.\n\n $help";}

if ($skipcheckprod==0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod") or die "Can't open < /opt/sap/cron_scripts/passwords/check_prod : $!";

my @prodline="";
while (<PROD>){
	@prodline = split(/\t/, $_);
	$prodline[1] =~ s/\n//g;
}

if ($prodline[1] eq "1" ){
	print "production server \n";
	die "This is the production server\n"
}
}

my $prodserver = $ARGV[0];
my $finTime = localtime();

print "Server Being Loaded: $prodserver\n";

if ($allowparallel==0){
my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep dump_databases.pl|grep -v grep|grep -v $my_pid|grep -v "vim dump_databases.pl"|grep -v "less dump_databases.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}
}

$finTime = localtime();
print $finTime . "\n";


my $sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
exec master.dbo.rp_kill_db_processes '$database'
go
declare \@count tinyint
declare \@dbname varchar(100)
set \@dbname='$database'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
while \@count>0
begin
waitfor delay '00:05:00'
select \@count=count(*) FROM master.dbo.sysprocesses sp where 1=1 and DB_NAME(sp.dbid) = \@dbname and cmd = 'DUMP DATABASE'
end
$cmd
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
To: $mail\@canpar.com
Subject: Errors - load_databases at $finTime

$sqlError
EOF
`;
die;
}else{
$finTime = localtime();
print "Time Finished: $finTime\n";
}
