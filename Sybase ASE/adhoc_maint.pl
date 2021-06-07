#!/usr/bin/perl

#Script:   		Script for scheduled adhoc maintenance.
#Feb 04 2021	Rafael Leandro		Originally created
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

my $error = `. /opt/sap/SYBASE.sh
isql_r -V -w1900 -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
use svp_cp
go
update statistics svp_parcel
go

use cpscan
go
update statistics tttl_ma_barcode
go

use cpscan
go
update statistics tttl_ma_shipment
go

use cpscan
go
update statistics tttl_ma_eput3
go

use cpscan
go
update statistics tttl_ma_document
go

use cpscan
go
update statistics tot_ma_st
go

use cmf_data
go
update statistics cmfshipr
go

use cpscan
go
update statistics tttl_pa_parcel
go

use cpscan
go
update statistics tttl_ev_event
go

use cpscan
go
update statistics tttl_ex_exception_comment
go

use cpscan
go
update statistics tttl_dc_delivery_comment
go

use cmf_data
go
update statistics points_no_ranges
go

use cmf_data_lm
go
update statistics points_no_ranges
go

use cmf_data
go
update statistics points_no_ranges
go

use cmf_data_lm
go
update statistics points_no_ranges
go

use cmf_data
go
update statistics tot_tm
go

EOF
`;

if($error =~ /Msg/)
{
print $error . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - adhoc_maint.pl script.
$error
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}else{
	print "success\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: SUCCESS - adhoc_maint.pl script.
Script adhoc_maint finished successfully. Remember to disable the job in the crontab.

Script name: $0.
EOF
`;
$finTime = localtime();
print $finTime . "\n";
}

