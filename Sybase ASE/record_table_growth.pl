#!/usr/bin/perl -w

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

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
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

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
exec hub_db..record_table_growth
go
exec scan_compliance..record_table_growth
go
exec cpscan..record_table_growth
go
exec lmscan..record_table_growth
go
exec cmf_data..record_table_growth
go
exec cmf_data_lm..record_table_growth
go
exec canship_webdb..record_table_growth
go
exec rev_hist..record_table_growth
go
exec rev_hist_lm..record_table_growth
go
exec canada_post..record_table_growth
go
exec svp_lm..record_table_growth
go
exec svp_cp..record_table_growth
go
exec canshipws..record_table_growth
go
exec cdpvkm..record_table_growth
go
exec collectpickup..record_table_growth
go
exec collectpickup_lm..record_table_growth
go
exec dqm_data_lm..record_table_growth
go
exec sort_data..record_table_growth
go
exec liberty_db..record_table_growth
go
exec eput_db..record_table_growth
go
exec evkm_data..record_table_growth
go
exec linehaul_data..record_table_growth
go
--exec lm_stage..record_table_growth
--go
exec pms_data..record_table_growth
go
exec rate_update..record_table_growth
go
exec shippingws..record_table_growth
go
exec termexp..record_table_growth
go
exec uss..record_table_growth
go
exec mpr_data..record_table_growth
go
exec mpr_data_lm..record_table_growth
go
insert into dba..db_space
select db_name(d.dbid) as db_name
,ceiling(sum(case when u.segmap != 4 and vdevno >= 0 then (u.size/1048576.)*\@\@maxpagesize end )) as data_size_MB
,ceiling(sum(case when u.segmap != 4 and vdevno >= 0 then convert(bigint,size) - curunreservedpgs(u.dbid, u.lstart, u.unreservedpgs) end)/1048576.*\@\@maxpagesize) as data_used_MB
,ceiling(sum(case when u.segmap = 4 and vdevno >= 0 then u.size/1048576.*\@\@maxpagesize end)) as log_size_MB
,ceiling(sum(case when u.segmap = 4 and vdevno >= 0 then u.size/1048576.*\@\@maxpagesize end) - lct_admin("logsegment_freepages",d.dbid)/1048576.*\@\@maxpagesize) as log_used_MB
,ceiling(sum(case when u.segmap != 4 and vdevno >= 0 then (u.size/1048576.)*\@\@maxpagesize end )) - ceiling(sum(case when u.segmap != 4 and vdevno >= 0 then convert(bigint,size) - curunreservedpgs(u.dbid, u.lstart, u.unreservedpgs) end)/1048576.*\@\@maxpagesize) as UnusedDataSpace_MB
,ceiling(sum(case when u.segmap = 4 and vdevno >= 0 then u.size/1048576.*\@\@maxpagesize end)) - ceiling(sum(case when u.segmap = 4 and vdevno >= 0 then u.size/1048576.*\@\@maxpagesize end) - lct_admin("logsegment_freepages",d.dbid)/1048576.*\@\@maxpagesize) as UnusedLogSpace_MB
,ceiling(sum(case when u.segmap != 4 and vdevno >= 0 then (u.size/1048576.)*\@\@maxpagesize end )) + ceiling(sum(case when u.segmap = 4 and vdevno >= 0 then u.size/1048576.*\@\@maxpagesize end)) as TotalDatabaseSpace_MB
,getdate() as SnapTime
,(select max(SnapId)+1 from  dba..db_space) as SnapId
from master..sysdatabases d, master..sysusages u
where u.dbid = d.dbid  and d.status != 256
and u.dbid not in (select dbid from master..sysdatabases where name like 'tempdb%')
and d.name not in ('sybsystemdb','sybsystemprocs','sybmgmtdb','master','model')
group by d.dbid
order by TotalDatabaseSpace_MB desc
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$currTime = localtime();
print "record_table_growth FinTime: $currTime\n";