#!/usr/bin/perl -w

#Description:	Deletes old data from auxiliary tables in lm_stage database.
#Jun 12	2013	Amer Khan 		Originally created
#Sep 01	2019	Rafael Leandro	Modified to call a procedure to cleanup the ev_event table.
#								The proc will cleanup the table in several small transactions to prevent locks in the database and reduce replication stress
#Dec 17	2019	Rafael Leandro	Added deadlock retry logic 
#								Added basic parameterization
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
use lm_stage
go
delete employee_login where scanner_drained_at < dateadd(dd,-40,getdate())
go
delete tttl_dr_delivery_record where conv_time_date < convert(datetime,convert(date,getdate()))
go
delete tttl_ex_exception_comment where updated_on_cons < convert(datetime,convert(date,getdate()))
go
delete tttl_io_interline_outbound where updated_on_cons < convert(datetime,convert(date,getdate()))
go
delete tttl_pr_pickup_record where updated_on_cons < convert(datetime,convert(date,getdate()))
go
delete tttl_ps_pickup_shipper where updated_on_cons < convert(datetime,convert(date,getdate()))
go
delete tttl_pt_pickup_totals where updated_on_cons < convert(datetime,convert(date,getdate()))
go
declare \@status int, \@retry int, \@maxretry int
set \@retry = 0
set \@maxretry = 50
execute \@status = purge_tttl_ev_event

while \@status = -3 and \@retry <= \@maxretry
begin
set \@retry=\@retry+1
WAITFOR DELAY '00:01:00'
execute \@status = purge_tttl_ev_event
end

if \@retry = \@maxretry
select 'Maxinum number of deadlock retries reached.'
go
exit
EOF
`;

print $sqlError."\n";
$currTime = localtime();

if($sqlError =~ /Msg 1205/ && $sqlError =~ /Maxinum number of deadlock retries reached./){
	print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - lm_stage_purge_data

Maximum deadlock retries reached. Check the messages below for more info.
$sqlError
EOF
`;

die "There were errors in this lm_stage_purge_data at $currTime \n";
}elsif($sqlError =~ /Msg/ && $sqlError != /Maxinum number of deadlock retries reached./)
{
	print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - lm_stage_purge_data

Following status was received during lm_stage_purge_data that started on $currTime
$sqlError
EOF
`;

die "There were errors in this lm_stage_purge_data at $currTime \n";
}

$currTime = localtime();
print "lm_stage_purge_data FinTime: $currTime\n";

