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
my $tsize=20;

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
and d.name not in ('sybsystemdb','sybsystemprocs','sybmgmtdb','master','model')
and d.name not like ('tempdb%')
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
<title>HTML E-mail</title>
</head>
<body>
<p>Check below the list of database whose log sizes are beyond the threshold.</p>

<table border=\"1\">
<tr><td>database</td><td>isMixed</td><td>TotalMB</td><td>UsedMB</td><td>FreeMB</td><td>logUsed_pct</td></tr>\n";
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

$htmlmail .= "<p>Following are the list of entries in the syslogshold table.</p>\n";

my $logshold = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select s.spid,'#',db_name(s.dbid) as 'database','#',starttime,'#',datediff(mi,s.starttime,getdate()) as duration,'#',name,'#',isnull(sp.status,"orphan entry") as status
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

$htmlmail .="<table border=\"1\">
<tr><td>spid</td><td>database</td><td>starttime</td><td>duration</td><td>name</td><td>status</td></tr>\n";

@results="";
@line="";
$htmltable="";
@results = split(/\n/,$logshold);

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
Subject: Database log size alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

Script name: $0. Current threshold: $tsize%.

EOF
`;
}
else{
$finTime = localtime();
print "No log bloat detected at $finTime\n";
}