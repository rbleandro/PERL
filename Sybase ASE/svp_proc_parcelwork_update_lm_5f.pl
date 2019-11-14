#!/usr/bin/perl -w

##############################################################################
#Description: This script runs the proc parcelwork procedures                #
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Dec 16 2013	Amer Khan 	Modified for Loomis                          #
#                                                                            #
##############################################################################

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

print "svp_proc_parcelwork For Loomis StartTime: $currTime, Hour: $startHour, Min: $startMin\n";
#if (1==2){
$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep svp_proc_parcelwork_update_lm.pl|grep -v grep|grep -v $my_pid|grep -v "vim svp_proc_parcelwork_update_lm.pl"|grep -v "less svp_proc_parcelwork_update_lm.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "Start svp_parcel_url_execution_lm: $currTime \n";

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_lm
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 5,\'svp_parcel_del_eval_execution_lm\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
go
exit
EOF
`;

`/opt/sap/cron_scripts/svp_parcel_del_eval_execution_lm.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_del_eval_execution_lm.log`;

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_lm
go
declare \@now datetime
select \@now = max(start_date) from svp_lm..svp_status_run where  job_name=\'svp_parcel_del_eval_execution_lm\' and seq = 5
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_parcel_del_eval_execution_lm\' and seq = 5 and start_date=\@now
go
exit
EOF
`;

#}# AA  End of If

#Execute source_of_failure in the end...
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_lm
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 6,\'svp_proc_source_failure\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_source_failure
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_source_failure\' and seq = 6 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 7,\'svp_proc_notmade_service\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_notmade_service
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_notmade_service\' and seq = 7 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 8,\'svp_proc_parcel_deltermupdation\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_parcel_deltermupdation
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_parcel_deltermupdation\' and seq = 8 and start_date=\@now
go
exit
EOF
`;

print "Msgs from svp_proc_source_failure $sqlError \n";
if($sqlError =~ /Msg/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Error - Canpar sp_proc_parcel_cp - Error in srouce failre procs

Following status was received during sp_proc_parcel that started on $currTime
$sqlError

EOF
`;

}


#########
####Executing url for parcel batch###
##########
$currTime = localtime();
print "Start svp_parcel_url_execution_lm: $currTime \n";

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_lm
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 9,\'svp_parcel_url_execution_lm\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
go
exit
EOF
`;

`/opt/sap/cron_scripts/svp_parcel_url_execution_lm.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_url_execution_lm.log`;

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_lm
go
declare \@now datetime
select \@now = max(start_date) from svp_lm..svp_status_run where  job_name=\'svp_parcel_url_execution_lm\' and seq = 9
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_parcel_url_execution_lm\' and seq = 9 and start_date=\@now
go
exit
EOF
`;

#Execute feeding stats in the end...
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_lm
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 10,\'feed_svp_stats\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute feed_svp_stats
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'feed_svp_stats\' and seq = 10 and start_date=\@now
go
declare \@now datetime
set \@now=getdate()
insert into svp_lm..svp_status_run values ( 11,\'feed_svp_origin_stats\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute feed_svp_origin_stats
update svp_lm..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'feed_svp_origin_stats\' and seq = 11 and start_date=\@now
go
exit
EOF
`;

if($sqlError =~ /Msg/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Error - Loomis sp_proc_parcel_cp - Error in feeding stats table

Following status was received during sp_proc_parcel that started on $currTime
$sqlError

EOF
`;

}


$currTime = localtime();
print "Loomis svp_proc_parcel FinTime: $currTime\n";

`touch /tmp/svp_parcel_proc_lm_done`;
