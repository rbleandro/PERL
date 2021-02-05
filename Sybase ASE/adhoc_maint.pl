#!/usr/bin/perl

#Script:   	Script for scheduled adhoc maintenance.
#Author:   	Rafael Leandro
#Date			Name				Description
#---------------------------------------------------------------------------------
#Feb 04 2021	Rafael Leandro		Originally created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
my @prodline="";

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro\n";

if ($skipcheckprod == 0){
	open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
	while (<PROD>){
		@prodline = split(/\t/, $_);
		$prodline[1] =~ s/\n//g;
	}
	close PROD;
	if ($prodline[1] eq "0" ){
		print "standby server \n";
		die "This is a stand by server\n";
	}
}

my $prodserver = hostname();
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w1900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
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
Subject: ERROR - adhoc_maint.pl script.
Script adhoc_maint finished successfully. Remember to disable the job in the crontab.
EOF
`;
$finTime = localtime();
print $finTime . "\n";
}

