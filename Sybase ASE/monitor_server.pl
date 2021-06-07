#!/usr/bin/perl

#Script:   	This script monitor CPU load, alerting when above 95%. This script relies on the sqsh component. Consult the sharepoint documentation to see how to install it.
#09/22/2018     Rafael Leandro  Created
#Aug 10 2019	Rafael Leandro	1.Reformatting of the sql queries and perl commands. Elimination of obsolete code.
#                               2.Review of thread report query
#								3.Changed the script to use sqsh when sending the report (better formatting)
#								4.Parameterized the alert threshold (check variable $tcpu) and the mail recipient
#Aug 08 2019   	Rafael Leandro  Added html support for a better look in the final email.
#May 19 2020   	Rafael Leandro  Changed the query to get the number of sessions per application to be more accurate and informative.
#May 02 2021    Rafael Leandro  Included cumulative duration and added check for weekend
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
my $tcpu=95;
my $cpu=0;


GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help,
	'threshold|t=i' => \$tcpu
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

#if it is a weekend, bring the threshold down a bit
my $wday = (localtime)[6];
if (($wday eq 0 || $wday eq 6) && $tcpu eq 98){
     $tcpu=80;  
}

#Execute CPU Monitoring
my $error = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b<<EOF 2>&1
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

send_alert($error,"Msg|Error|failed",$noalert,$mail,$0,"get server counters");

$error =~ s/\s//g;
$error =~ s/\t//g;
$cpu=$error;

if ($cpu > $tcpu)
{
	
my $htmlmail="<html>
<head>
<title>Sybase CPU load Alert</title>
<style>
table {
# border-collapse: collapse;
}
table, th, td {
# border: 1px solid blue;
}
td {
# padding: 5px;
# text-align: left;
}
th {
# background-color: #99bfac;
# color: white;
# padding: 5px;
# text-align: center;
}
</style>
</head>
<body>
<p>CPU now (%): $cpu. Please check. Below is a report of number of active sessions per application. Execute the queries at the end to see server trends and historical data.</p>
<table>";

my $NumConnections = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -w900 -n -b<<EOF 2>&1
set nocount on
go
Select count(a.SPID) as '#Sessions','###',p.Login,'###',case when p.ClientApplName is null then isnull(p.Application,sp.ipaddr) else p.ClientApplName end as Application,'###',p.DBName,'###'
, sum(a.CPUTime) as CumulativeCPU,'###', sum(a.PhysicalReads) as CumulativePhyReads,'###', sum(a.LogicalReads) as CumulativeLogReads,'###'
--, sum(sp.execution_time) as CumulativeDuration
,convert(varchar(2),floor(sum(sp.execution_time) / (1000 * 60 * 60 * 24))) + 'd:' + convert(varchar(2),floor(sum(sp.execution_time) / (1000 * 60 * 60)) % 24) + 'h:' + convert(varchar(2),floor(sum(sp.execution_time) / (1000 * 60)) % 60) + 'm:' + convert(varchar(2),floor(sum(sp.execution_time) / (1000)) % 60) + 's'
From master..monProcessActivity a, master..monProcess p, master..monProcessStatement s,master.dbo.sysprocesses sp
Where a.SPID = p.SPID and a.KPID = p.KPID and a.SPID = s.SPID and a.KPID = s.KPID and p.SPID=sp.spid and p.KPID=sp.kpid
and sp.status not in ('recv sleep','background')
and sp.execlass is not null
and sp.suid <> 0
group by p.Login,case when p.ClientApplName is null then isnull(p.Application,sp.ipaddr) else p.ClientApplName end,p.DBName
order by sum(a.CPUTime) desc
go
exit
EOF
`;

send_alert($NumConnections,"Msg|Error|failed",$noalert,$mail,$0,"get current sessions");

$NumConnections=~s/\t//g;

my @results="";
my $htmltable="<th>#Sessions</th><th>Login</th><th>Application</th><th>DBName</th><th>CumulativeCPU</th><th>CumulativePhyReads</th><th>CumulativeLogReads</th><th>CumulativeDuration</th>";
my $td="";
@results = split(/\n/,$NumConnections);
for (my $i=0; $i <= $#results; $i++){
	my @line = split(/###/,$results[$i]);
	$htmltable.="<tr>";
	for (my $l=0; $l <= $#line; $l++){
		 $td.="<td>" . $line[$l] . "</td>";
	}
	$htmltable.=$td;
	$htmltable.="</tr>";
	$td="";
}

$htmlmail .= $htmltable . "</table><br>\n";

$htmlmail.="<table><th>Active Process History</th><tr><td>select top 100 * from dba.dbo.dba_mon_processes where snapTime=(select max(snapTime) from dba.dbo.dba_mon_processes) order by program</td></tr></table><br>
<table><th>CPU Load History</th><tr><td>select top 10 * from dba.dbo.server_health order by SnapTime desc</td></tr></table><br>
<table><th>Heaviest Queries by CPU</th><tr><td>Select top 20 a.SPID, p.Login,case when p.ClientApplName is null then isnull(p.Application,sp.ipaddr) else p.ClientApplName end as Appication,p.DBName, p.Command, a.CPUTime, a.PhysicalReads, a.LogicalReads
From master..monProcessActivity a, master..monProcess p, master..monProcessStatement s,master.dbo.sysprocesses sp
Where a.SPID = p.SPID and a.KPID = p.KPID and a.SPID = s.SPID and a.KPID = s.KPID and p.SPID=sp.spid and p.KPID=sp.kpid
Order by a.CPUTime desc
go</td></tr></table><br>
<p>Script's name: $0. Current threshold: $tcpu%.</p>
</body>
</html>\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Server load alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail
EOF
`;
}
else
{
print "CPU is now(%): $cpu\n";
}
