#!/usr/bin/perl

#Script:   script to apply the same command on all server databases
#April 8th 2021	Rafael			Originally created

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

my $error = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
select name
from master..sysdatabases 
where 1=1
and name not in ('master','model','sybmgmtdb','sybsecurity','sybsystemdb','sybsystemprocs')
and name not like 'tempdb%'
order by name
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"get database list");

$error=~s/\t//g;
$error=~s/ //g;

my @results = split(/\n/,$error);

for (my $i=0; $i <= $#results; $i++){

print "executing for database $results[$i]\n";
$sqlError .= `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -i /opt/sap/cron_scripts/multi_script_exec.txt -D $results[$i]`;
}

send_alert($sqlError,"Msg",$noalert,$mail,$0,"execute script");

$currTime = localtime();
print "Process FinTime: $currTime\n";
