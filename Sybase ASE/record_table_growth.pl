#!/usr/bin/perl -w
#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();
#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));
print "record_table_growth StartTime: $currTime, Hour: $startHour, Min: $startMin\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
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
print $sqlError."\n";
if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - record_table_growth
Following status was received during record_table_growth that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "record_table_growth FinTime: $currTime\n";