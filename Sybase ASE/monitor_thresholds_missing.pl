#!/usr/bin/perl

#Script:   		This script monitors missing database thresholds
#May 22 2020	Rafael Leandro	Initial version
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
my $tspace=1000;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help,
	'threshold|t=i' => \$tspace
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
isql_r -V -S$prodserver -w900 -b<<EOF 2>&1
set nocount on
set proc_return_status off
go
exec dba.dbo.populate_threshold_control
go
select t1.dbname,'#',t1.segname,'#'
,'consider creating a new threshold for ' + cast((case when (case t1.segname when 'logsegment' then s.logSize*0.25 else s.dataSize*0.25 end) > 5000 then 5000 else (case t1.segname when 'logsegment' then s.logSize*0.25 else s.dataSize*0.25 end) end) as varchar(50)) as SitRep,'#'
,s.TotalDatabaseSpace,'#',s.dataSize,'#',s.logSize,'#'
,'exec '+t1.dbname+'..sp_addthreshold '+t1.dbname+', "'+t1.segname+'", '+ cast((case when (case t1.segname when 'logsegment' then s.logSize*0.25 else s.dataSize*0.25 end) > 5000 then 5000 else (case t1.segname when 'logsegment' then s.logSize*0.25 else s.dataSize*0.25 end) end)*512 as varchar(50)) +', sp_thresholdNOaction'
from dba.dbo.threshold_control t1
inner join dba.dbo.db_space_rep s on s.db_name=t1.dbname
where 1=1
and not exists
    (
        select t2.segname 
        from dba.dbo.threshold_control t2 
        inner join dba.dbo.db_space_rep s1 on s1.db_name=t2.dbname 
        where t1.dbname = t2.dbname and t1.segname=t2.segname 
        group by t2.segname
        having max(t2.space_threshold_MB) >= (case when (case t2.segname when 'logsegment' then s1.logSize*0.25 else s1.dataSize*0.25 end) > 5000 then 5000 else (case t2.segname when 'logsegment' then s1.logSize*0.25 else s1.dataSize*0.25 end) end)
    )
and s.TotalDatabaseSpace > 1000
group by dbname,segname
,'consider creating a new threshold for ' + case t1.segname when 'logsegment' then cast(s.logSize*0.25 as varchar(50)) else cast(s.dataSize*0.25 as varchar(50)) end 
,s.TotalDatabaseSpace,s.dataSize,s.logSize
go
exit
EOF
`;

send_alert($error,"no|not|Msg",$noalert,$mail,$0,"get missing thresholds");

$error=~s/\t//g;

if ($error =~ /#/){

my $htmlmail="<html>
<head>
<title>Sybase threshold missing alert</title>
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
<p>Check below the list of databases missing thresholds. It is important that databases have at least 1 threshold pointing to an action procedure.</p>

<table>
<th>dbname</th><th>segname</th><th>recommendation</th><th>TotalDatabaseSpace</th><th>dataSize</th><th>logSize</th><th>command</th>\n";
my @results="";
my $htmltable="";
my $td="";

@results = split(/\n/,$error);

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

my $error2 = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b -w400<<EOF 2>&1
set nocount on
set proc_return_status off
go
select d.name as dbname,'#',isnull(t.segname,'') as segname,'#',isnull(t.space_threshold_MB,-99) as space_threshold_MB,'#','No segment threshold defined. Please solve ASAP.' as SitRep,'#'
,s.TotalDatabaseSpace,'#',s.dataSize,'#',s.logSize
from master..sysdatabases d
left join dba.dbo.threshold_control t on d.name = t.dbname 
inner join dba.dbo.db_space_rep s on s.db_name=d.name
where 1=1
and d.name not in ('master','model','sybmgmtdb','sybsecurity','sybsystemdb','sybsystemprocs')
and t.space_threshold_MB is null
and s.TotalDatabaseSpace > 1000
go
exit
EOF
`;

send_alert($error2,"no|not|Msg",$noalert,$mail,$0,"");

@results="";
$htmltable="<br><table><th>dbname</th><th>segname</th><th>space_threshold_MB</th><th>recommendation</th><th>TotalDatabaseSpace</th><th>dataSize</th><th>logSize</th>\n";
$td="";

@results = split(/\n/,$error2);

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

$htmlmail .= "<p>Script name:$0. Current database size threshold: $tspace (milliseconds)</p>\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Missing database thresholds
Content-Type: text/html
MIME-Version: 1.0

$htmlmail
EOF
`;
}
else{
$finTime = localtime();
print "No missing thresholds at $finTime\n";
}