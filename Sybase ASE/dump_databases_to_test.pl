#!/usr/bin/perl -w

#Description:	This script will dump the database on production, copy the file to the test server and 
#				load it there, sending an email with the outcome at the end.
#
#May 01 2018	Rafael Bahia	Originally created
#Mar 30 2019	Rafael Bahia	Added parameter validation and email recipient customization
#Apr 03 2019	Rafael Bahia	Changed the script to allow the execution of more than one instance
#May 29 2019	Rafael Bahia	Added error handling for the scp phase

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $option=0;
my $noalert=0;
my $finTime = localtime();
my $checkProcessRunning=1; #if 0 (zero), allows multiple instances of the script to run in parallel
my $prodserver = hostname();
my $originDB = "";
my $destDB = "";
my @prodline = "";

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'loadoption|l=i' => \$option,
	'origindb=s' => \$originDB,
	'noalert' => \$noalert,
	'destdb=s' => \$destDB
) or die "Usage: $0 --originDB dba --destDB dba --skipcheckprod|s 0 --to|r rleandro --loadoption|l 1|0\n";

if ($originDB eq "") {die "\nDatabase name (parameter --originDB) cannot be blank.\n\n";}

isProd($skipcheckprod);
checkProcessByName($checkProcessRunning,$0);

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

my $testserver = '10.3.1.165';

#Set starting variables
my $currTime = localtime();

print "CurrTime: $currTime\n";

#Cleaning up the backup volume to free space (deletes all files older than 7 days)
#my $deleteoldfiles =`sudo find /opt/sap/db_backups/ -mindepth 1 -mtime +60 -delete`;

my $sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
dump database $originDB to "/opt/sap/db_backups/$originDB.dmp" compression=100
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"dump database");

#Copying files to TEST server
my $scpError=system("scp -p /opt/sap/db_backups/$originDB.dmp sybase\@$testserver:/opt/sap/db_backups");

if ($scpError != 0) {
print "$scpError\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_test (scp phase) at $finTime

$scpError
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent";
}

if ($option == 1){

#Loading databases into TEST server
my $load_msgs = `ssh $testserver /opt/sap/cron_scripts/load_databases_to_test.pl $originDB $destDB $mail`;

print "$load_msgs \n";
}
else {
print "Database was dumped and the file copied to the destination server but Load was not processed. Do it manually.\n"
}

$finTime = localtime();
print "Time Finished: $finTime\n";
