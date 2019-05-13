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
$startMonth=sprintf('%02d',((localtime())[4]));
$startDay=sprintf('%02d',((localtime())[3]));
$startYear=sprintf('%02d',((localtime())[5]));

$startMonth += 1; #Month in perl starts from 0 and ends on 11.
$startYear += 1900; #Needed to get correct 4digit year.

$today = "$startMonth/$startDay/$startYear";

print "svp_proc_parcelwork For Canpar StartTime: $currTime, Hour: $startHour, Min: $startMin\n";
#if (1==2){
$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep svp_proc_parcelwork_update_cp.pl|grep -v grep|grep -v $my_pid|grep -v "vim svp_proc_parcelwork_update_cp.pl"|grep -v "less svp_proc_parcelwork_update_cp.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


#########################################
# Should only run if the last day
# in inserted_on_cons of svp_parcel_work
# is one day prior to todays date
#########################################
#if (1==2) { #Conditional skip to avoid the following until the End OF If . See }
$sqlDateCheck = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
set nocount on
go
select datediff(dd,max(inserted_on_cons),'$today') from svp_parcel
go
exit
EOF
`;

$sqlDateCheck =~ s/\s//g;

if ($sqlDateCheck < 2){
   print "Data is uptodate\n";
   die;
}#else{ print "Need to run update\n"; die; }


#Execute source_of_failure in the end...

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 7,\'svp_proc_source_failure\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
--execute svp_proc_source_failure
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_source_failure\' and seq = 7 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 8,\'svp_proc_notmade_service\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_notmade_service
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_notmade_service\' and seq = 8 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 9,\'manifested_failed_pcs\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute manifested_failed_pcs
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'manifested_failed_pcs\' and seq = 9 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 10,\'svp_proc_source_failure_trailer\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_source_failure_trailer
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_source_failure_trailer\' and seq = 10 and start_date=\@now
go
exit
EOF
`;

$currTime = localtime();

print "Start svp_parcel_url_execution_cp: $currTime \n";

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 11,\'svp_parcel_url_execution_cp\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
go
exit
EOF
`;

system("/opt/sap/cron_scripts/svp_parcel_url_execution_cp.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_url_execution_cp.log 2>&1");

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
select \@now = max(start_date) from svp_cp..svp_status_run where  job_name=\'svp_parcel_url_execution_cp\' and seq = 11
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_parcel_url_execution_cp\' and seq = 11 and start_date=\@now
go
exit
EOF
`;

print "Msgs from svp_proc_source_failure $sqlError \n";

if($sqlError =~ /Msg/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Error - Canpar sp_proc_parcel_cp

Following status was received during sp_proc_parcel that started on $currTime
$sqlError

EOF
`;

}

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 12,\'feed_svp_stats\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute feed_svp_stats
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'feed_svp_stats\' and seq = 12 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 13,\'feed_svp_origin_stats\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute feed_svp_origin_stats
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'feed_svp_origin_stats\' and seq = 13 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 14,\'feed_svp_stats_interline\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute feed_svp_stats_interline
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'feed_svp_stats_interline\' and seq = 14 and start_date=\@now
go
exit
EOF
`;

if($sqlError =~ /Msg/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Error - Canpar sp_proc_parcel_cp - Error in feeding stats table

Following status was received during sp_proc_parcel that started on $currTime
$sqlError

EOF
`;

}


$currTime = localtime();
print "Canpar svp_proc_parcel FinTime: $currTime\n";

`touch /tmp/svp_parcel_proc_cp_done`;
