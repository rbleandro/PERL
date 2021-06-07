#!/usr/bin/perl -w

#Script:          This script loads data into vp_alltotals of mpr_data from etime
#Date             Name            Description
#Oct 6, 2008	Amer Khan		Initial version
#April 30,2020	Rafael Bahia	Enhanced error checking. Added check for file existence before BCP op

#Usage Restrictions
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
isql_r -V -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
truncate table vp_alltotals
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"vp_alltotals");

if (-e "/opt/sap/bcp_data/mpr_data/vp_alltotals.dat"){
$sqlError = `bcp_r mpr_data..vp_alltotals in /opt/sap/bcp_data/mpr_data/vp_alltotals.dat -V -S$prodserver -c -t"|:|" -r"||\r\n"`;
}

print $sqlError."\n";
$currTime = localtime();

if($sqlError =~ /failed|Error|Msg/){
      print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - bcp vp_alltotals

Following status was received during bcp in of vp_alltotals that started on $currTime
$sqlError
EOF
`;
}else{ #All is well, so proceed to processing data into secondary tables....

# Process data from vp_alltotals into secondary tables...
$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -w300 <<EOF 2>&1
use mpr_data
go
execute vp_alltotals_feed
go
exit
EOF
`;
}
print "$sqlError\n";

$currTime = localtime();
if($sqlError =~ /Msg/){
      print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - vp_alltotals_feed

Following status was received during execution of vp_alltotals_feed that started on $currTime
$sqlError
EOF
`;
}else
{ `touch /tmp/emp_time_load_done`;
}

$currTime = localtime();
print "Process FinTime: $currTime\n";
