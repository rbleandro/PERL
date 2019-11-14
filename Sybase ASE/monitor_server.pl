#!/usr/bin/perl

#Script:   	This script monitor CPU load, alerting when above 95%. This script relies on the sqsh component. Consult the sharepoint documentation to see how to install it.
#
#Author:   		Rafael Leandro
#Date			Name			Description
#---------------------------------------------------------------------------------
#09/22/2018     Rafael Leandro  Created
#Aug 10 2019	Rafael Leandro	1.Reformatting of the sql queries and perl commands. Elimination of obsolete code.
#								2.Review of thread report query
#								3.Changed the script to use sqsh when sending the report (better formatting)
#								4.Parameterized the alert threshold (check variable $tcpu) and the mail recipient
#16/08/19   	Rafael Leandro  Added html support for a better look in the final email.

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $hour=sprintf('%02d',((localtime())[2]));
$hour = int($hour);
my $tcpu=95;
my $cpu=0;

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'threshold|t=i' => \$tcpu
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 80\n";

if ($skipcheckprod == 0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
}

my $prodserver = hostname();
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

#Execute CPU Monitoring

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
set proc_return_status off
go
exec dba.dbo.sp_monitor_server_custom
go
select top 1 cpu_busy from dba.dbo.server_health order by SnapTime desc
go
exit
EOF
`;

if($error =~ /no|not|Msg/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_server script (get current metrics phase).
$error
EOF
`;
die "Email sent";
}

$error =~ s/\s//g;
$error =~ s/\t//g;
$cpu=$error;

if ($cpu > $tcpu)
{

my $NumConnections = `. /opt/sap/SYBASE.sh
isql -w900 -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
go
SELECT
CASE sp.clienthostname WHEN '' THEN isnull(sp.hostname,sp.ipaddr) WHEN NULL THEN isnull(sp.hostname,sp.ipaddr) ELSE sp.clienthostname END 'host','#',
CASE clientapplname WHEN '' THEN program_name WHEN NULL THEN program_name ELSE clientapplname END 'program','#',
SUSER_NAME(suid) as username,'#',
count(spid) as 'NumSessions'
FROM master.dbo.sysprocesses sp
where 1=1
and status not in ('background')
and cmd not in ('HK WASH','HK GC','HK CHORES','NETWORK HANDLER','MEMORY TUNE','DEADLOCK TUNE','SHUTDOWN HANDLER','KPP HANDLER','ASTC HANDLER','CHECKPOINT SLEEP','PORT MANAGER','AUDIT PROCESS','CHKPOINT WRKR','LICENSE HEARTBEAT','JOB SCHEDULER')
and status <> 'recv sleep'
group by CASE clientapplname WHEN '' THEN program_name WHEN NULL THEN program_name ELSE clientapplname END, SUSER_NAME(suid)
,CASE sp.clienthostname WHEN '' THEN isnull(sp.hostname,ipaddr) WHEN NULL THEN isnull(sp.hostname,ipaddr) ELSE sp.clienthostname END,
SUSER_NAME(suid) 
order by count(spid) desc
go
exit
EOF
`;

if($NumConnections =~ /Msg/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_server script (get sessions per app phase).
$NumConnections
EOF
`;
die "Email sent (get sessions per app)";
}

$error=~s/\t//g;

my @results="";
my $htmltable="<tr><td>host</td><td>program</td><td>username</td><td>NumSessions</td></tr>";
my $td="";
@results = split(/\n/,$NumConnections);
for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>";
	}
	$htmltable.=$td;
	$htmltable.="</tr>";
	$td="";
}

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Server load alert!!!
Content-Type: text/html
MIME-Version: 1.0

<html>
<head>
<title>HTML E-mail</title>
</head>
<body>
<p>CPU now (%): $cpu. Please check. Below is a report of number of active sessions per application. Execute the queries at the end to see server trends and historical data.</p>
<table border="1">
$htmltable
</table>
<p>select top 100 * from dba.dbo.dba_mon_processes where snapTime=(select max(snapTime) from dba.dbo.dba_mon_processes) order by program</p>
<p>select top 10 * from dba.dbo.server_health order by SnapTime desc</p>
<p>Script's name: $0. Current threshold: $tcpu%.</p>
</body>
</html>
EOF
`;
}
else
{
print "CPU is now(%): $cpu\n";
}
