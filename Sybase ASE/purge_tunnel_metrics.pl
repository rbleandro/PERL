#!/usr/bin/perl -w

#Description: This script deletes any records which are older than six months on weekly basis                                                
#Oct 01 2014	Amer Khan 	Originally created                           
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
isql_r -V -S$prodserver -b -n<<EOF 2>&1
use cpscan
go
declare \@dateVar datetime
select \@dateVar = dateadd(mm,-6,getdate())
delete cpscan..tunnel_metrics from cpscan..tunnel_metrics (index id_1idx) where scan_date_time < \@dateVar
go
exit
EOF
`;

send_alert($sqlError,"Msg|Error|failed",$noalert,$mail,$0,"");
$currTime = localtime();
print "purge_tunnel_metrics FinTime: $currTime\n";

