#!/usr/bin/perl -w

#Script:   This script purges overhead_package_scans data older than 60 days
#Feb 1 2017	Amer Khan	Created
#May 10 2021	Rafael Leandro 	Added several features and enabled kerberos auth

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

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use sort_data
go
if datename(dw,getdate()) = 'Sunday'
begin
set rowcount 2500000
delete sort_data..overhead_package_scans
from sort_data..overhead_package_scans (index idxupd) where updated_on < dateadd(dd, -45, getdate())
end
else
begin
set rowcount 150000
delete sort_data..overhead_package_scans
from sort_data..overhead_package_scans (index idxupd) where updated_on < dateadd(dd, -45, getdate())
end
go
exit
EOF
`;

send_alert($sqlError,"Msg|Error|failed",$noalert,$mail,$0,"");
$finTime = localtime();
print "Time Finished: $finTime\n";
