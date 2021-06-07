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
execute update_consignee_city
go
select  conv_time_date,employee_num,delivery_rec_num,consignee_city = t2.minor_city+','+t2.province_code
into #consignee_info
from tttl_dr_delivery_record t1 (index tttl_dr_nc_ioc), canada_post..all_minor_cities t2
where t1.consignee_postal_code = t2.postal_code
and t1.consignee_postal_code <> ''
and (t1.consignee_city = '' or t1.consignee_city is null)
and t1.inserted_on_cons > dateadd(dd,-3,getdate())
go
update tttl_dr_delivery_record
set consignee_city = con.consignee_city
from tttl_dr_delivery_record tdr, #consignee_info con
where tdr.conv_time_date = con.conv_time_date
and tdr.employee_num = con.employee_num
and tdr.delivery_rec_num = con.delivery_rec_num
go
exit
EOF
`;

send_alert($sqlError,"Msg|not",$noalert,$mail,$0,"exec proc");

$currTime = localtime();
print "Process FinTime: $currTime\n";
