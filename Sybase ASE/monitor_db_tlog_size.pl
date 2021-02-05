#!/usr/bin/perl

#Script:   	This script checks the databases' log sizes and alerts in case they are above the threshold.
#Author:   	Rafael Leandro
#Revision:
#Date			Name				Description
#---------------------------------------------------------------------------------
#Aug 18 2019	Rafael Leandro		Originally created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $tsize=25;

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'threshold|t=i' => \$tsize
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 10\n";

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

if ($tsize == -9) {
	$tsize = 0.4;
}


my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w1900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select db_name(d.dbid) as db_name,'#'
,case d.status2 & 32768 when 32768 then 'Yes' else 'No' end isMixed,'#'
,sum(convert(bigint,u.size)/512) as TotalMB,'#'
,case d.status2 & 32768 when 32768 then ((lct_admin("num_logpages", d.dbid)) + (sum(u.size)/256))/512
 else sum(convert(bigint,u.size)/512) - (lct_admin("logsegment_freepages", d.dbid) - lct_admin("reserved_for_rollbacks", d.dbid))/512
 end as UsedMB,'#'
,(lct_admin("logsegment_freepages", d.dbid) - lct_admin("reserved_for_rollbacks", d.dbid))/512  as FreeMB,'#'
,convert(decimal(16,2), (100 * (case d.status2 & 32768 when 32768 then ((lct_admin("num_logpages", d.dbid)) + (sum(u.size)/256.))/512.
 else sum(convert(bigint,u.size)/512.) - (lct_admin("logsegment_freepages", d.dbid) - lct_admin("reserved_for_rollbacks", d.dbid))/512.
 end ))/ sum(convert(bigint,u.size)/512.)) as logUsed_pct
from master..sysdatabases d, master..sysusages u
where u.dbid = d.dbid  and d.status != 256
and u.segmap & 4 = 4
and d.name not in (
    select name
    from master..sysdatabases
    where status3 & (select  number from master.dbo.spt_values where   type = "D3" and name = "user created temp db") != 0
    AND name NOT IN
    (
        select a.object_cinfo from master..sysattributes a, master..sysattributes b
        where a.class = 16
        AND b.class = 16
        AND a.object_type = 'D '
        AND b.object_type = 'GR'
        AND a.object = b.int_value
    )
)
group by d.dbid
having (convert(decimal(16,2), (100 * (case d.status2 & 32768 when 32768 then ((lct_admin("num_logpages", d.dbid)) + (sum(u.size)/256.))/512.
 else sum(convert(bigint,u.size)/512.) - (lct_admin("logsegment_freepages", d.dbid) - lct_admin("reserved_for_rollbacks", d.dbid))/512.
 end ))/ sum(convert(bigint,u.size)/512.))) > $tsize
order by convert(decimal(16,2), (100 * (case d.status2 & 32768 when 32768 then ((lct_admin("num_logpages", d.dbid)) + (sum(u.size)/256.))/512.
 else sum(convert(bigint,u.size)/512.) - (lct_admin("logsegment_freepages", d.dbid) - lct_admin("reserved_for_rollbacks", d.dbid))/512.
 end ))/ sum(convert(bigint,u.size)/512.)) desc
go
EOF
`;

if($error =~ /Msg/)
{
print $error . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_dblog_size.pl script.
$error
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

$error =~ s/\t//g;

if ($error =~ /#/){

my $htmlmail="<html>
<head>
<title>Sybase transaction log size alert</title>
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
<p>Check below the list of database whose log sizes are beyond the threshold.</p>

<table >
<tr><th>database</th><th>isMixed</th><th>TotalMB</th><th>UsedMB</th><th>FreeMB</th><th>logUsed_pct</th></tr>\n";
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

if ($error =~ /Yes/){

$htmlmail .= "<p><b><font color='red'>It looks like you have a database with mixed segments (check column isMixed in the table above).
You should separate the log segment from the other segments to allow database recovery in case of disk failure.
Consult the documentation and use the procedure sp_logdevice to address this situation.</font></b></p>\n";
}

$htmlmail .= "<p>Following are the processes for the databases whose log are filled beyond the threshold. Duration is shown in minutes. Check the list below for a reference for the transaction state info:
<br>1-Begun/2-Done Command/3-Done/4-Prepared/5-In Command/6-In Abort Cmd/7-Committed/8-In Post Commit/9-In Abort Tran
10-In Abort Savept/65537-Begun-Detached/65538-Done Cmd-Detached/65539-Done-Detached/65540-Prepared-Detached/65548-Heur Committed/65549-Heur Rolledback
</p>\n";

my $affdb = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select s.spid,'#',db_name(s.masterdbid),'#'
,isnull(execution_time/1000/60,-1) as execution_time,'#'
,p.status,'#'
,physical_io,'#'
,suser_name(p.suid) as "user",'#'
,isnull(CASE clientapplname WHEN '' THEN program_name WHEN NULL THEN program_name ELSE clientapplname END,'Unknown') 'program','#'
,CASE clienthostname WHEN '' THEN isnull(hostname,ipaddr) WHEN NULL THEN isnull(hostname,ipaddr) ELSE clienthostname END 'host','#'
,s.state as TranState,'#'
,'exec sp_showplan('+cast(p.spid as varchar(100))+')' as getPlan,'#'
,'dbcc sqltext('+cast(p.spid as varchar(100))+')' as getQuery
from master..systransactions s 
left join master..sysprocesses p on p.spid=s.spid 
where 1=1  and db_name(p.dbid) in 
(
	select db_name(d.dbid)
	from master..sysdatabases d, master..sysusages u
	where u.dbid = d.dbid  and d.status != 256
	and u.segmap & 4 = 4
	and d.name not in (
		select name
		from master..sysdatabases
		where status3 & (select  number from master.dbo.spt_values where   type = "D3" and name = "user created temp db") != 0
		AND name NOT IN
		(
			select a.object_cinfo from master..sysattributes a, master..sysattributes b
			where a.class = 16
			AND b.class = 16
			AND a.object_type = 'D '
			AND b.object_type = 'GR'
			AND a.object = b.int_value
		)
	)
	group by d.dbid
	having (convert(decimal(16,2), (100 * (case d.status2 & 32768 when 32768 then ((lct_admin("num_logpages", d.dbid)) + (sum(u.size)/256.))/512.
	 else sum(convert(bigint,u.size)/512.) - (lct_admin("logsegment_freepages", d.dbid) - lct_admin("reserved_for_rollbacks", d.dbid))/512.
	 end ))/ sum(convert(bigint,u.size)/512.))) > $tsize
)

go
EOF
`;

if($affdb =~ /Msg/)
{
print $affdb . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_dblog_size.pl script.
$affdb
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

$htmlmail .= "<table >
<th>spid</th><th>database</th><th>duration</th><th>status</th><th>physical_io</th><th>username</th><th>program</th><th>host</th><th>Tran State</th><th>getPlan</th><th>getQuery</th>\n";

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

$htmlmail .= "<p>Following are the list of entries in the syslogshold table.</p>\n";

my $logshold = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select s.spid,'###',db_name(s.dbid) as 'database','###',starttime,'###',datediff(mi,s.starttime,getdate()) as duration,'###',name,'###',isnull(sp.status,"orphan entry") as status
from master..syslogshold s
left join master..sysprocesses sp on s.spid = sp.spid
where 1=1
and s.spid<>0
go
EOF
`;

if($logshold =~ /Msg/)
{
print $logshold . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_dblog_size.pl script.
$logshold
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

$htmlmail .="<table >
<th>spid</th><th>database</th><th>starttime</th><th>duration</th><th>name</th><th>status</th>\n";

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

$htmlmail .= $htmltable . "</table><p>Script name: $0. Current threshold: $tsize%.</p>\n";

$htmlmail .= "</body></html>\n\n";


`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Database log size alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

EOF
`;
}
else{
$finTime = localtime();
print "No log bloat detected at $finTime\n";
}