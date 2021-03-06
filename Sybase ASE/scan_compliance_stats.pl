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

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use scan_compliance
go
declare \@startdate date
declare \@enddate date

set \@enddate = dateadd(dd,-7,getdate())
set \@startdate = dateadd(dd,-8,getdate())

execute ScanComplianceStats \@startdate, \@enddate,0

select 'Procedure ScanComplianceStats executed for start date = ' + convert(varchar(50),\@startdate) + ' and end date = ' + convert(varchar(50),\@enddate)
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$currTime = localtime();
print "Process FinTime: $currTime\n";
