#!/usr/bin/perl

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
my $cput=1000;
my $tcache=10;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'cputhreshold|ct=i' => \$cput,
	'hitratiothreshold|hrt=i' => \$tcache,
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

my @results="";
my @line="";
my $htmltable="";
my $td="";
my $spid = 0;

my $htmlmail="<html>
<head>
<title>Sybase server health report</title>
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
<body>";

$htmlmail .= "<p>Following is a summary of CPU utilization. Data from the last 7 days. More details can be found in table dba.dbo.server_health.</p>\n";

my $affdb = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select avg(cpu_busy) as AvgCPU,'#',max(cpu_busy) as MaxCPU,'#',min(cpu_busy) as MinCPU
from dba.dbo.server_health 
where SnapTime > dateadd(day,-7,getdate()) 
go
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$htmlmail .= "<table >
<th>AvgCPU</th><th>MaxCPU</th><th>MinCPU</th>\n";

@results="";
@line="";
$htmltable="";
@results = split(/\n/,$affdb);

for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";

$htmlmail .= "<p>Following is the cache hit ratio for all caches configured. If number are below 90%, it is possible that you are doing too much physical IO.</p>\n";

my $logshold = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select * into #moncache_prev 
from master..monDataCache

waitfor delay "00:$tcache:00"

select * into #moncache_cur
from master..monDataCache

select p.CacheName, '###',
"Hit Ratio"=convert(decimal(20,2),((c.LogicalReads-p.LogicalReads) - (c.PhysicalReads - p.PhysicalReads)) * 100./ (c.LogicalReads - p.LogicalReads))
from #moncache_prev p, #moncache_cur c 
where p.CacheName = c.CacheName
and c.LogicalReads <> p.LogicalReads
go
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$htmlmail .="<table><th>Cache Name</th><th>Cache Hit Ratio</th>\n";

@results="";
@line="";
$htmltable="";
@results = split(/\n/,$logshold);

for (my $i=0; $i <= $#results; $i++){
	@line = split(/###/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";

$htmlmail .= "<p>Below distribution for the most relevant wait statistics. Use it to check what are the bottlenecks in the server. All the numbers are cumulative since the last server restart.</p>\n";

my $waits = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select case ServerUserID when 0 then "Y" else "N" end as "Server",'#',
Description,'#', convert(bigint,sum(convert(bigint,w.Waits))) as "Count",'#'
,convert(bigint,sum(convert(bigint,w.WaitTime))/1000) as "Seconds"
from    master..monProcessWaits w,master..monWaitEventInfo ei
where   w.WaitEventID   = ei.WaitEventID
and ServerUserID != 0
group   by case ServerUserID when 0 then "Y" else "N" end,Description
having convert(bigint,sum(convert(bigint,w.WaitTime))/1000) > 250000
order by 1,convert(bigint,sum(convert(bigint,w.WaitTime))/1000) desc
go
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$htmlmail .="<table>
<th>Server Wait?</th><th>Wait Description</th><th>#Occurrences</th><th>Wait Time</th>\n";

@results="";
@line="";
$htmltable="";
@results = split(/\n/,$waits);

for (my $i=0; $i <= $#results; $i++){
	@line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";

$htmlmail .= "<p>To check performance tuning opportunities, check the table dba.dbo.heavy_queries by running the query below:<br>
select SQLText,max(CpuTime) as CPUTime,max(SnapTime) as SnapTime,max(SPID) as spid
from dba.dbo.heavy_queries
where 1=1
group by SQLText<br>
go.<br></p>\n";

$htmlmail .= "<p>Below is the list of unbound temporary databases. Bind these ASAP (you might have to restart the server to do so) or drop them to liberate resources.</p>\n";
$htmlmail.="<table><th>Tempdb Name</th><th>Status</th>\n";

my $utempdb = `. /opt/sap/SYBASE.sh
isql_r -V -w20000 -S$prodserver -n -b <<EOF 2>&1
use dba
go
set nocount on
set proc_return_status OFF
go
exec return_unbound_tempdb
go
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

@results="";
@line="";
$htmltable="";
@results = split(/\n/,$utempdb);

for (my $i=0; $i <= $#results; $i++){
	@line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table>\n";

$htmlmail .= "<p>Script name: $0. CPU threshold: $cput milliseconds. Cache collection interval: $tcache minute.</p>";
$htmlmail .= "</body></html>\n\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Weekly Server Health Report
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

EOF
`;

$currTime = localtime();
print "Process FinTime: $currTime\n";
