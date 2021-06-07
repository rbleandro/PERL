#!/usr/bin/perl

#Script:   		This script monitors sessions running for more than 60 minutes in the database
#Jan 1 2020		Rafael Leandro		Originally created
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
my $threshold=600000;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'threshold|t=i' => \$threshold,
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
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
DECLARE \@clockrate int
set \@clockrate  = (select convert(int,cc.value2) from master.dbo.syscurconfigs cc inner join master.dbo.sysconfigures sc on cc.config=sc.config where sc.name='sql server clock tick length')

select sp.spid,'#'
,CASE sp.cmd  WHEN 'NETWORK HANDLER' THEN NULL ELSE DB_NAME(sp.dbid) END 'Database','#'
,convert(varchar(2),floor(execution_time / (1000 * 60 * 60 * 24))) + 'd:' + convert(varchar(2),floor(execution_time / (1000 * 60 * 60)) % 24) + 'h:' + convert(varchar(2),floor(execution_time / (1000 * 60)) % 60) + 'm:' + convert(varchar(2),floor(execution_time / (1000)) % 60) + 's' as 'duration'
,'#',sp.status,'#', SUSER_NAME(sp.suid) 'user','#'
,CASE sp.clienthostname WHEN '' THEN sp.hostname WHEN NULL THEN sp.hostname ELSE sp.clienthostname END 'host','#'
,CASE sp.clientapplname  WHEN '' THEN sp.program_name WHEN NULL THEN sp.program_name ELSE sp.clientapplname END 'program','#'
,sp.memusage,'#', sp.cpu*\@clockrate/1000 as 'CPU(ms)','#', sp.physical_io,'#', sp.blocked 'blkpid'
FROM master.dbo.sysprocesses sp
where 1=1 and sp.spid <> \@\@spid
and sp.cmd not in ('HK WASH','HK GC','HK CHORES','NETWORK HANDLER','MEMORY TUNE','DEADLOCK TUNE','SHUTDOWN HANDLER','KPP HANDLER','ASTC HANDLER','CHECKPOINT SLEEP','PORT MANAGER','AUDIT PROCESS','CHKPOINT WRKR','LICENSE HEARTBEAT','JOB SCHEDULER')
and sp.status not in ('background')
and sp.status <> 'recv sleep'
and execution_time > $threshold
and sp.spid not in (select spid from dba.dbo.sessionWhiteList)
go
exit
EOF
`;


send_alert($error,"Msg",$noalert,$mail,$0,"get sessions");


$error =~ s/\t//g;

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
<p>Check below the list of long running sessions in the database. Please check if the session is stuck with the running status with unchanging resource utilization metrics (you might have to kill and restart the process if that is the case). Duration is shown in hours.</p>

<table border=\"1\">
<th>spid</th><th>database</th><th>duration</th><th>status</th><th>user</th><th>host</th><th>program</th><th>memusage</th><th>cpu</th><th>physical_io</th><th>blocked</th>\n";

my @results="";
my $htmltable="";
my $td="";
my $spid = 0;

@results = split(/\n/,$error);

for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
		if ($i ==0){$spid=$line[0]}
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table></body></html>\n";


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


send_alert($error2,"Msg",$noalert,$mail,$0,"get plan");


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
Subject: Long running sessions alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

<p>Script name:$0. Current threshold: $threshold (milliseconds)</p>

EOF
`;
}
else{
$finTime = localtime();
print "No long running sessions detected at $finTime\n";
}