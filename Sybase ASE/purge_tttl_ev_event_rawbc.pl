#!/usr/bin/perl -w

#Script:       This script deletes all records from tttl_ev_event_rawbc
#              which are more than a month old.
#              This script is scheduled to run every day
#Dec 12 2015	Amer Khan	Originally created
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
isql_r -V -S$prodserver <<EOF
use lmscan
go
exec purge_eventrawbc
go
exit
EOF
`;

send_alert($sqlError,"no|not|Msg",$noalert,$mail,$0,"exec proc");

$currTime = localtime();
print "Process FinTime: $currTime\n";