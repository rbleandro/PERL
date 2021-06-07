#!/usr/bin/perl -w

#Script:   This script purges svp_lm..svp_parcel for data older than 2 years
#Author:	Amer Khan						     
#Feb 1 2017	Amer Khan	Created					     
#Aug 18 2019	Rafael Leandro	Changed the query to achieve better performance and also to impose less stress on replication
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
isql_r -V -S$prodserver <<EOF 2>&1
use svp_lm
go
declare \@count int
set \@count=1000
while \@count > 0
begin
delete top 1000 svp_lm..svp_parcel from svp_lm..svp_parcel (index idx9) where updated_on_cons < dateadd(yy,-2,getdate())
select \@count=\@\@rowcount
waitfor delay '00:00:02'
end
go
exit
EOF
`;

send_alert($sqlError,"Msg|Error|failed",$noalert,$mail,$0,"");
$finTime = localtime();
print "Time Finished: $finTime\n";
