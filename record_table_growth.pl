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
use cpscan
go
--update tbl_growth set SnapId=1
go
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,(select isnull(max(SnapId),0)+1 from tbl_growth) as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go
use lmscan
go
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,(select max(SnapId)+1 from dbo.tbl_growth) as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go
use cmf_data
go
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,(select isnull(max(SnapId),0)+1 from tbl_growth) as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go
use cmf_data_lm
go
declare \@count int
set \@count = (select count(*) from tbl_growth)
    
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,case \@count when 0 then 1 else (select isnull(max(SnapId),0)+1 from tbl_growth) end as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go
use mpr_data
go
declare \@count int
set \@count = (select count(*) from tbl_growth)
    
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,case \@count when 0 then 1 else (select isnull(max(SnapId),0)+1 from tbl_growth) end as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go

use mpr_data_lm
go
declare \@count int
set \@count = (select count(*) from tbl_growth)
    
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,case \@count when 0 then 1 else (select isnull(max(SnapId),0)+1 from tbl_growth) end as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go

use svp_cp
go
declare \@count int
set \@count = (select count(*) from tbl_growth)
    
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,case \@count when 0 then 1 else (select isnull(max(SnapId),0)+1 from tbl_growth) end as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
go

use svp_lm
go
--truncate table tbl_growth
declare \@count int
set \@count = (select count(*) from tbl_growth)
    
insert into tbl_growth (table_name,row_count,pages,kbs,SnapTime,SnapId)
select convert(varchar(30),o.name) AS table_name,
row_count(db_id(), o.id) AS row_count,
data_pages(db_id(), o.id, 0) AS pages,
(data_pages(db_id(), o.id, 0) * (\@\@maxpagesize/1024)) AS kbs
,getdate() as SnapTime
,case \@count when 0 then 1 else (select isnull(max(SnapId),0)+1 from tbl_growth) end as SnapId
from sysobjects o
where type = 'U'
order by kbs desc
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

