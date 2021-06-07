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
my $dbname="dba";

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
        'dbname|d=s' => \$dbname,
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

$currTime = localtime();

print "CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -b -n -S$prodserver <<EOF 2>&1
use $dbname
go
set nocount on
go
set proc_return_status off
go
set clientapplname 'maintainIndexStatistics'
go
insert into dba.dbo.sessionWhiteList (spid,inserted_on) values(\@\@spid,getdate())
go
exec maintainIndexStatistics
go
delete from dba.dbo.sessionWhiteList where spid=\@\@spid
go
exit
EOF
`;

send_alert($sqlError,"Msg|error",$noalert,$mail,$0,"exec proc");

