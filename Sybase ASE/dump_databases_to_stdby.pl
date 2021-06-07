#!/usr/bin/perl -w

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help
) or die showDefaultHelp(1,$0);

showDefaultHelp($help,$0);
checkProcessByName($checkProcessRunning,$0);
isProd($skipcheckprod);

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

$currTime = localtime();
print "StartTime: $currTime\n";

my $stbyserver;
if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

print "Prod: $prodserver....Stby: $stbyserver \n";

my $database = $ARGV[0];

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

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
insert into dba.dbo.sessionWhiteList (spid,inserted_on) values(\@\@spid,getdate())
go
dump database $database to "/opt/sap/db_backups/$database.dmp" compression=100
go
delete from dba.dbo.sessionWhiteList where spid=\@\@spid
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_stdby at $finTime

$sqlError
EOF
`;
die;
}

#Copying files to standby server
my $scpError;
$scpError=`scp -p /opt/sap/db_backups/$database.dmp sybase\@$stbyserver:/opt/sap/db_backups`;
print "$scpError\n";

$scpError  = $? >> 8;
if ($scpError != 0) {
print "$scpError\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_test (scp phase) at $finTime

$scpError
EOF
`;
die;
}

###############################
#Run load in standby server now
###############################

#Loading databases into standby server
my $load_msgs;
$load_msgs = `ssh $stbyserver /opt/sap/cron_scripts/load_databases_to_stdby.pl $database $mail $resumerep`;
#Loading databases into DR server
#$load_msgs_dr = `ssh $drserver /opt/sap/cron_scripts/load_databases_mpr.pl $drserver`;

print "$load_msgs \n";
#print "$load_msgs_dr \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
