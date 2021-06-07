#!/usr/bin/perl

#Script:   		Collects disk performance data and alerts when metrics are above the threshod
#May 13 2021	Rafael Leandro  Created

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
my $currTime="";
my $help=0;
my $sqlError="";
my $threshold=10;


GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help,
	'threshold|t=i' => \$threshold
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
isql_r -V -S$prodserver -n -b -w900<<EOF 2>&1
set nocount on
set proc_return_status off
go
exec dba.dbo.collect_disk_perf $threshold
go
select deviceScope,'#', msPerIO,'#', snaptime,'#', status from dba.dbo.disk_perf where snaptime = (select max(snaptime) from dba.dbo.disk_perf)
go
exit
EOF
`;

send_alert($error,"Msg|Error|failed",$noalert,$mail,$0,"collect and extract");

$error =~ s/\t//g;

if ($error =~ /BAD/)
{
	
my $htmlmail="<html>
<head>
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
<p>We're apparently having storage contention. Disk IOpS is above the current threshold of $threshold msPerIO. Check the times below and report it to StratosphereIQ or NOC. Adjust the threshold on the script if necessary.</p>
<table>
<tr><th>Device Scope</th><th>msPerIO</th><th>SnapTime</th><th>Status</th></tr>\n";

my @results="";
my @line="";
my $htmltable="";
my $td="";
my $spid = 0;

@results = split(/\n/,$error);

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
$htmlmail .= "</body></html>\n\n";


`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: High storage time!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

<p>This alert's threshold: $threshold msPerIO</p>
<p>Script location: $0</p>

EOF
`;

$currTime = localtime();
print "Process FinTime: $currTime\n";
}
else{
$finTime = localtime();
print "No disk contention detected at $finTime\n";
}
