#!/usr/bin/perl

#Script:   	This script checks for long running transactions that are preventing database log flush
#Aug 18 2019	Rafael Leandro		Originally created
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
my $tduration=30;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help,
	'threshold|t=i' => \$tduration
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
isql_r -V -w900 -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select s.spid,'#',db_name(s.dbid) as 'database','#',isnull(sp.spid,-9765) as process,'#',s.starttime,'#',datediff(mi,s.starttime,getdate()) as duration,'#'
,str_replace(s.name,'\$','') as trans,'#'
,isnull(suser_name(sp.suid),'Unknown') as username,'#',
isnull(CASE clientapplname WHEN '' THEN program_name WHEN NULL THEN program_name ELSE clientapplname END,'Unknown') as 'program','#',
isnull(CASE clienthostname WHEN '' THEN isnull(hostname,ipaddr) WHEN NULL THEN isnull(hostname,ipaddr) ELSE clienthostname END,'Unknown') as 'host'
from master..syslogshold s
left outer join master..sysprocesses sp on s.spid = sp.spid
where 1=1
and s.spid<>0
and datediff(mi,s.starttime,getdate()) > $tduration
and s.name not like '%DUMP DATABASE%'
and db_name(s.dbid) not like 'tempdb%'
order by s.starttime
go
EOF
`;


send_alert($error,"no|not|Msg",$noalert,$mail,$0,"exec proc");


$error =~ s/\t//g;

if ($error =~ /#/){

my $htmlmail="<html>
<head>
<title>HTML E-mail</title>
</head>
<body>
<p>Check below the list of long running sessions that are preventing the log from being purged. The execution plan is shown only for the longest transaction. Duration is shown in minutes.</p>

<table border=\"1\">
<tr><td>spid</td><td>database</td><td>sysprocess</td><td>starttime</td><td>duration</td><td>trans</td><td>username</td><td>program</td><td>host</td></tr>\n";
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
		if ($i ==0){$spid=$line[0];}
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";

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

$error2 =~ s/DBCC execution completed.*//g;
$error2 =~ s/Subordinate SQL Text: //g;
$error2 =~ s/SQL Text:.*//g;

#send_alert($error2,"no|not|Msg",$noalert,$mail,$0,"exec proc");

if ($error2 !~ /Possibly the query has not started or has finished executing/ && $error !~ /-9765/){
if ($error =~ /-9765/){

$htmlmail .= "<p><b><font color='red'>It looks like you have phantom entries in the syslogshold table. This is a serious issue that can cause database log bloat. 
Consider rebooting only the affected database to see if that clears its log.
If the database affected is a temporary database, make sure the database is out of the pool of temporary databases and that the connections to the database are killed. 
If database reboot does not work and/or the log keeps filling up, schedule a recycle of the database server. Run the query below to see the phantom entries.

select db_name(dbid),* from master..syslogshold s where 1=1 and not exists(select * from sysprocesses p where spid=s.spid)</font></b></p>\n";
}

if ($error2 =~ /MERGE JOIN/ || $error2 =~ /Positioning at start/ || $error2 =~ /Table Scan/ || $error2 =~ /This step involves sorting/){
	$htmlmail .= "<p><b><font color='red'>Heavy operations such as table scan or merge joins were detected in the execution plan. Review the query and the tables involved as soon as possible.</font></b></p>\n";
}
else
{
	$htmlmail .= "<p><b><font color='blue'>No heavy operations detected in the execution plan. You should still check if this query can be tunned, specially if it runs frequently during peak hours.</font></b></p>\n";
}

my $plandetails="";
my $linecontrol=1;

@results = split(/\n/,$error2);
for (my $i=0; $i <= $#results; $i++){
	if ($results[$i] =~ /\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\* END OF QUERY \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/){$plandetails.="<p>" . $results[$i] . "</p>"; $linecontrol=0;}
	if ($results[$i] =~ /QUERY PLAN/){$linecontrol=1;}
	if ($linecontrol==1){
		if ($results[$i] =~ /MERGE JOIN/ || $results[$i] =~ /Positioning at start/ || $results[$i] =~ /Table Scan/ || $results[$i] =~ /This step involves sorting/ || $results[$i] =~ /Positioning at index start/){
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
Subject: Long running transactions alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

Script name:$0.

EOF
`;
}
else{
$finTime = localtime();
print "Ignoring dormant processes at $finTime\n";
}
}
else{
$finTime = localtime();
print "No long running transactions detected at $finTime\n";
}