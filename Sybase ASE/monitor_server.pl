#!/usr/bin/perl

#Script:   	This script monitor CPU load, alerting when above 95%. This script relies on the sqsh component. Consult the sharepoint documentation to see how to install it.
#Author:   		Rafael Leandro
#09/22/2018     Rafael Leandro  Created
#Aug 10 2019	Rafael Leandro	1.Reformatting of the sql queries and perl commands. Elimination of obsolete code.
#								2.Review of thread report query
#								3.Changed the script to use sqsh when sending the report (better formatting)
#								4.Parameterized the alert threshold (check variable $tcpu) and the mail recipient
#Aug 08 2019   	Rafael Leandro  Added html support for a better look in the final email.
#May 19 2020   	Rafael Leandro  Changed the query to get the number of sessions per application to be more accurate and informative.

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
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -n -b<<EOF 2>&1
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
	
my $htmlmail="<html>
<head>
<title>Sybase CPU load Alert</title>
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
<p>CPU now (%): $cpu. Please check. Below is a report of number of active sessions per application. Execute the queries at the end to see server trends and historical data.</p>
<table>";

my $NumConnections = `. /opt/sap/SYBASE.sh
isql -w900 -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
go
Select count(a.SPID) as '#Sessions','###',p.Login,'###',case when p.ClientApplName is null then isnull(p.Application,sp.ipaddr) else p.ClientApplName end as Application,'###',p.DBName,'###'--, p.Command
, sum(a.CPUTime) as CumulativeCPU,'###', sum(a.PhysicalReads) as CumulativePhyReads,'###', sum(a.LogicalReads) as CumulativeLogReads
From master..monProcessActivity a, master..monProcess p, master..monProcessStatement s,master.dbo.sysprocesses sp
Where a.SPID = p.SPID and a.KPID = p.KPID and a.SPID = s.SPID and a.KPID = s.KPID and p.SPID=sp.spid and p.KPID=sp.kpid
group by p.Login,case when p.ClientApplName is null then isnull(p.Application,sp.ipaddr) else p.ClientApplName end,p.DBName--, p.Command
order by sum(a.CPUTime) desc
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
my $htmltable="<th>#Sessions</th><th>Login</th><th>Application</th><th>DBName</th><th>CumulativeCPU</th><th>CumulativePhyReads</th><th>CumulativeLogReads</th>";
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
