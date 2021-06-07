#!/usr/bin/perl -w

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use lib ('/opt/sap/cron_scripts/lib');
use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

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
use cpscan
go
update shipper
set updated_on_cons = getdate()
--select *
from shipper s where pickup_days_of_week <> ''
and s.updated_on_cons > dateadd(dd,-10,getdate())
and s.customer_num not in (select p.customer from cmf_data..disp_cust p where s.customer_num = p.customer)
go
use lmscan
go
update shipper
set updated_on_cons = getdate()
--select *
from shipper s where pickup_days_of_week <> ''
and s.updated_on_cons > dateadd(dd,-10,getdate())
and s.customer_num not in (select p.customer from cmf_data_lm..disp_cust p where s.customer_num = p.customer)
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$finTime = localtime();
print "Time Finished: $finTime\n";
