#!/usr/bin/perl

#Script:   		This script monitors process memory usage. Anything above the baseline generates an alert
#Jun 18 2019	Rafael Bahia	Originally created
#Jul 5 2019		Rafael Bahia	Removed day execution restrictions
#May 4 2020     Rafael Bahia    Alert will now include culprit sessions. Script is now parameterized.
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
my $tmem=6000;
my $tmemtotal=300000;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help,
	'limittotal|ttot=i' => \$tmemtotal,
    'limitproc|tproc=i' => \$tmem
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
isql_r -V -S$prodserver -n -b <<EOF 2>&1
set nocount on
select sum(memusage)
from master..sysprocesses
where 1=1
go
exit
EOF
`;


send_alert($error,"no|not|Msg",$noalert,$mail,$0,"exec proc");


$error =~ s/\s//g;
$error =~ s/\t//g;

print $error."\n";

if ($error > $tmemtotal){
        
$error = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
select spid,'#',DB_NAME(dbid) as 'database','#',isnull(execution_time/1000/60,-1) as execution_time,'#',status,'#',memusage,'#',physical_io,'#',isnull(suser_name(suid),'Unknown') as username,'#',
isnull(CASE clientapplname WHEN '' THEN program_name WHEN NULL THEN program_name ELSE clientapplname END,'Unknown') 'program','#',
CASE clienthostname WHEN '' THEN isnull(hostname,ipaddr) WHEN NULL THEN isnull(hostname,ipaddr) ELSE clienthostname END 'host','#'
,'exec sp_showplan('+cast(spid as varchar(100))+')' as getPlan,'#'
,'dbcc sqltext('+cast(spid as varchar(100))+')' as getQuery
from master..sysprocesses
where 1=1
and status <> 'recv sleep'
and memusage > $tmem
go
exit
EOF
`;


send_alert($error,"no|not|Msg",$noalert,$mail,$0,"exec proc");


$error=~s/\t//g;

if ($error =~ /#/){

my $htmlmail="<html>
<head>
<title>Sybase Monitor Memory Usage</title>
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
<p>Check below the list of sessions using high amounts of memory. Execution plan and query info is for the first displayed session only.</p>

<table border=\"1\">
<tr><th>spid</th><th>database</th><th>duration</th><th>status</th><th>memory</th><th>physical_io</th><th>username</th><th>program</th><th>host</th><th>getPlan</th><th>getQuery</th></tr>\n";
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
		if ($i ==0){$spid=$line[0];$user=$line[6];}
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";
$htmlmail .= "<p>Total memory usage in Sybase crossed the baseline. This can cause resource starvation and lead to connection problems for new processes trying to logon to the databases. Please check ASAP.</p>";

if ($spid == 0) {die "Could not find spid\n";}

my $error2 = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b -w400<<EOF 2>&1
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


send_alert($error2,"no|not|Msg",$noalert,$mail,$0,"exec proc");


$error2 =~ s/DBCC execution completed.*//g;
$error2 =~ s/Subordinate SQL Text: //g;
$error2 =~ s/SQL Text:.*//g;


if ($error2 =~ /MERGE JOIN/ || $error2 =~ /Positioning at start/ || $error2 =~ /Table Scan/ || $error2 =~ /This step involves sorting/ || $error2 =~ /Positioning at index start/){
	$htmlmail .= "<p><b><font color='red'>Heavy operations such as table scan or merge joins were detected in the execution plan. Review the query and the tables involved as soon as possible.</font></b></p>\n";
}
else
{
	$htmlmail .= "<p><b><font color='blue'>No heavy operations detected in the execution plan. You should still check if this query can be tunned, specially if it runs frequently during peak hours.</font></b></p>\n";
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
		if (($results[$i] =~ /MERGE JOIN/ || $results[$i] =~ /Positioning at start/ || $results[$i] =~ /Table Scan/ || $results[$i] =~ /This step involves sorting/ || $results[$i] =~ /Positioning at index start/) && $temptable==0){
			$plandetails.="<p style=\"background-color: #FF0000\"><font color='white'>" . $results[$i] . "</font></p>";
			
		}else{
			$plandetails.="<p>" . $results[$i] . "</p>";
		}
		
	}else{
		next;
	}
}

$htmlmail .= $plandetails . "</body></html>\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Process memory alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

Script name: $0. Total memory utilization threshold is $tmemtotal. Process memory utilization threshold is $tmem.

EOF
`;
}
else{
$finTime = localtime();
print "No memory leakage at $finTime\n";
}
}
