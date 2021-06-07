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
use mpr_data
go
declare \@fiscal int
select \@fiscal= (period - 1) from cmf_data..tot_pe where year =year(getdate()) and getdate() between start_date and end_date
if \@fiscal = 0 select \@fiscal = 12
exec load_master_record \@fiscal
go
use mpr_data_lm
go
declare \@fiscal int
select \@fiscal= (period - 1) from cmf_data_lm..tot_pe where year =year(getdate()) and getdate() between start_date and end_date
if \@fiscal = 0 select \@fiscal = 12
exec load_master_record \@fiscal
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$finTime = localtime();
print "Time Finished: $finTime\n";
print "Any messages.............\n";
print "*******************\n $sqlError \n********************\n";

