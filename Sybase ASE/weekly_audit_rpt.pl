#!/usr/bin/perl -w


#Script:   This script formats the Sybase audit data and sends the final report via email
#
#Author:   Ahsan Ahmed
#Revision: Rafael Leandro
#
#11/01/07		Ahsan Ahmed		Originally created
#May 10 2019	Rafael Leandro	Modified to add the DBA team to the final group and to remove obsolete mail recipients as well. Added error handling for the procedure call.
#May 29 2019	Rafael Leandro	Removed data treatment from the script. All data treatment is now done at the database view level.
#May 29 2019	Rafael Leandro	Simplified the bcp_r command (less control characters).
#May 29 2019	Rafael Leandro	Added file compression. Now that we are auditing more events and expanding their details, we need to reduce the final file size.

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
isql_r -V -S$prodserver -w300 <<EOF 2>&1
use sybsecurity
go
execute audit_thresh
go
exit
EOF
bcp_r sybsecurity..audit_report_vw out /tmp/audit_report_vw.tdl -V -S$prodserver -c -t"\t"
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/ || $sqlError =~ /Error/ || $sqlError =~ /ERROR/ || $sqlError =~ /error/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - weedkly_audit_rpt at $finTime

$sqlError
EOF
`;
die;
}

`rm /tmp/audit_report_vw.tdl.gz`;
`gzip /tmp/audit_report_vw.tdl`;


`/usr/bin/mutt -s "Database weekly changes - Audit report"  servicedesk\@canpar.com,forourke\@canpar.com,jpepper\@canpar.com,CANPARDatabaseAdministratorsStaffList\@canpar.com -a /tmp/audit_report_vw.tdl.gz <<EOF
Here is your weekly audit report for database changes on Sybase production server.

Please assign this ticket to Frank O'Rourke in development.

Thanks,
The DBA team.
EOF
`;
