#!/usr/bin/perl

#Script:   	This script monitors IOS over 1000000
#
#Author:   	Ahsan Ahmed
#Revision:
#Date			Name			Description
#---------------------------------------------------------------------------------
#11/01/07   	Ahsan Ahmed     Modified
#Aug 16 2019	Rafael Leandro	1.Completely revamped to add flags and parameters.
#								2.Also added support for html for the final email alert. The final alert is also much cleaner.
#								3.The script now shows all the sessions doing large IO instead of just one.

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $tio=100000;
my $autokill=0;

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'threshold|t=i' => \$tio
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 100000\n";

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
my $tiosec=$tio*2;
#print $tiosec . "\n";

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

#Execute IO Monitoring

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -b<<EOF 2>&1
set nocount on
go
if object_id('dba.dbo.sessionWhiteList') is not null
begin
delete from dba.dbo.sessionWhiteList where inserted_on is null
delete from dba.dbo.sessionWhiteList where inserted_on < dateadd(hh,-24,getdate())
end
go
select spid,'#',DB_NAME(dbid) as 'database','#',isnull(execution_time/1000/60,-1) as execution_time,'#',status,'#',physical_io,'#',isnull(suser_name(suid),'Unknown') as username,'#',
isnull(CASE clientapplname WHEN '' THEN program_name WHEN NULL THEN program_name ELSE clientapplname END,'Unknown') 'program','#',
CASE clienthostname WHEN '' THEN isnull(hostname,ipaddr) WHEN NULL THEN isnull(hostname,ipaddr) ELSE clienthostname END 'host','#'
,'exec sp_showplan('+cast(spid as varchar(100))+')' as getPlan,'#'
,'dbcc sqltext('+cast(spid as varchar(100))+')' as getQuery
from master..sysprocesses
where physical_io > (case 	when clientapplname like 'rpt_%' then $tio*4
							when clientapplname like 'dqm_freight_dist%' then $tiosec*4
							when clientapplname like 'qsp_getRTSListbyTerm' then $tiosec
							when clientapplname like 'generate_svb_data%' then $tio*7
							when clientapplname like 'svb_generate_%' then $tio*10
							when clientapplname like 'scan_compliance_update_cp' then $tio*4
							when clientapplname like 'svp_%' then $tio*6
							when clientapplname like 'process_parcel_records_missing' then $tio*3
							when clientapplname like 'feed_svp_origin_stats' then $tio*10
							when clientapplname like 'feed_svp_stats' then $tio*7
							when clientapplname like 'feed_svp_stats_interline' then $tio*10
							when clientapplname like 'update_cmfmetricsty' then $tio*20
							when clientapplname like 'svp_proc_source_failure' then $tiosec*2
							when clientapplname like 'lh_actual_dpts' then $tio*5
							when clientapplname like 'qsp_getRTSListbyTerm' then $tio*2
							when clientapplname like 'cmfaudit_move_history' then $tio*2
							when isnull(suser_name(suid),'Unknown') in ('sybmaint','DBA') then $tio*3						
							else $tio end )
and suid > 0
and status <> 'recv sleep'
and suser_name(suid) not in ('sybmaint')
--and cmd not like 'UPDATE STATISTICS%'
and spid not in (select spid from dba.dbo.sessionWhiteList)
order by physical_io desc
go
exit
EOF
`;

if($error =~ /Msg/)
{
print $error . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_ios script (get current blocks phase).
$error
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

$error=~s/\t//g;

if ($error =~ /#/){

my $htmlmail="<html>
<head>
<title>HTML E-mail</title>
<style>
table {
  border-collapse: collapse;
}
table, th, td {
  border: 1px solid black;
}
td {
  padding: 5px;
  text-align: left;
}
th {
  background-color: #99bfac;
  color: white;
  padding: 5px;
  text-align: center;
}
</style>
</head>
<body>
<p>Check below the list of sessions doing large IO. The following plan is for the heaviest session only. For more details about the other sessions, run dbcc sqltext and sp_showplan. Duration is shown in minutes.</p>

<table border=\"1\">
<th>spid</th><th>database</th><th>duration</th><th>status</th><th>physical_io</th><th>username</th><th>program</th><th>host</th><th>getPlan</th><th>getQuery</th>\n";
my @results="";
my $htmltable="";
my $td="";
my $io = 0;
my $user = "";
my $spid = 0;

@results = split(/\n/,$error);

for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
		if ($i ==0){$spid=$line[0];$user=$line[5];}
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";

if ($spid == 0) {die "Could not find spid\n";}

my $error2 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b -w400<<EOF 2>&1
set nocount on
set proc_return_status off
go
dbcc traceon(3604) dbcc sqltext($spid) dbcc traceoff(3604)
go
select '************************** END OF QUERY **************************'
go
sp_showplan $spid
go
exit
EOF
`;

if($error2 =~ /Msg/)
{
print $error2;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_ios script(get execution plans phase).
$error2
EOF
`;
$finTime = localtime();
print $finTime;
die "Email sent";
}

$error2 =~ s/DBCC execution completed.*//g;
$error2 =~ s/Subordinate SQL Text: //g;
$error2 =~ s/SQL Text:.*//g;
if ($error2 =~ /SELECT top 1 evt.status,evt.scan_time_date/ && $error2 =~ /evt.status='RTN'/ && $error2 =~ /evt.scan_time_date >='1900-01-01 00:00:00.000'/ && $error2 =~ /order by evt.scan_time_date desc/){
$autokill=1;
my $kill = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b -w400<<EOF 2>&1
kill $spid
go
exit
EOF
`;

if($kill =~ /Msg/)
{
print $kill;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_ios script(kill process).
$kill
EOF
`;
$finTime = localtime();
print $finTime;
die "Email sent";
}
}

if ($error2 =~ /MERGE JOIN/ || $error2 =~ /Positioning at start/ || $error2 =~ /Table Scan/ || $error2 =~ /This step involves sorting/ || $error2 =~ /Positioning at index start/ || $error2 =~ /Positioning at index end/){
	$htmlmail .= "<p><b><font color='red'>Heavy operations such as table scan or merge joins were detected in the execution plan. Review the query and the tables involved as soon as possible.</font></b></p>\n";
}
else
{
	$htmlmail .= "<p><b><font color='blue'>No heavy operations detected in the execution plan. You should still check if this query can be tunned, specially if it runs frequently during peak hours.</font></b></p>\n";
}

if ($autokill == 1){
	$htmlmail .= "<p><b><font color='blue'>Session $spid was automatically killed. Please check with development what can be done to tune the query.</font></b></p>\n";
}

my $plandetails="";
my $linecontrol=1;
my $fromtable=0;
my $temptable=0;
my $rttflag=0;

@results = split(/\n/,$error2);
for (my $i=0; $i <= $#results; $i++){
	if ($results[$i] =~ /\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\* END OF QUERY \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/){$plandetails.="<p>" . $results[$i] . "</p>"; $linecontrol=0;}
	if ($results[$i] =~ /QUERY PLAN/){$linecontrol=1;}
	
	if ($linecontrol==1){
		if ($results[$i] =~ /FROM TABLE/){$fromtable=1;$rttflag=0;}
		if ($results[$i] =~ /#/ && $fromtable==1){$temptable=1;$fromtable=0;}
		if ($results[$i] =~ /Using I\/O/){$temptable=0;}
		if (($results[$i] =~ /MERGE JOIN/ || $results[$i] =~ /Positioning at start/ || $results[$i] =~ /Table Scan/ || $results[$i] =~ /This step involves sorting/ || $results[$i] =~ /Positioning at index start/ || $results[$i] =~ /Positioning at index end/) && $temptable==0){
			$plandetails.="<p style=\"background-color: #FF0000\"><font color='white'>" . $results[$i] . "</font></p>";
			
		}else{
			$plandetails.="<p>" . $results[$i] . "</p>";
		}
		
	}else{
		next;
	}
}

$htmlmail .= $plandetails . "</body></html>\n";

#print $htmlmail . "\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Large IO Detected By $user!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail
EOF
`;
}
else{
$finTime = localtime();
print "No high IOs at $finTime\n";
}