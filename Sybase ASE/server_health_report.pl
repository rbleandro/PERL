#!/usr/bin/perl

#Script:   	This script checks the databases' log sizes and alerts in case they are above the threshold.
#Author:   	Rafael Leandro
#Date								Name												Description
#May 18 2020	Rafael Leandro		Originally created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $cput=1000;
my $tcache=10;

GetOptions(
 'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'cputhreshold|ct=i' => \$cput,
	'hitratiothreshold|hrt=i' => \$tcache
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --cputhreshold|ct 10 --hitratiothreshold|hrt\n";

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
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

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
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select avg(cpu_busy) as AvgCPU,'#',max(cpu_busy) as MaxCPU,'#',min(cpu_busy) as MinCPU
from dba.dbo.server_health 
where SnapTime > dateadd(day,-7,getdate()) 
go
EOF
`;

if($affdb =~ /Msg/)
{
print $affdb . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - server_health_report.pl script (CPU stats phase).
$affdb
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

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
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
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

if($logshold =~ /Msg/)
{
print $logshold . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - server_health_report.pl script (cache hit ratio phase).
$logshold
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

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
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
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

if($waits =~ /Msg/)
{
print $waits . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - server_health_report.pl script (wait stats phase).
$waits
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

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
isql -Usybmaint -w20000 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
use dba
go
set nocount on
set proc_return_status OFF
go
exec return_unbound_tempdb
go
EOF
`;

if($utempdb =~ /Msg/)
{
print $utempdb . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - server_health_report.pl script (heavy queries phase).
$utempdb
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

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
