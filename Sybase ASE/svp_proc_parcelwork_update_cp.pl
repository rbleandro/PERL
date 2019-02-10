#!/usr/bin/perl -w

##############################################################################
#Description: This script runs the proc parcelwork procedures                #
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Dec 16 2013	Amer Khan 	Modified for Canpar                          #
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

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
set clientapplname \'Canpar_svp_proc_parcel_update--Step 1\'
go
declare \@run_date date
declare \@now datetime
set \@now=getdate()
select \@run_date = dateadd(dd,1,max(inserted_on_cons)) from svp_parcel
select \"Running for following date\:\", \@run_date
insert into svp_cp..svp_status_run values ( 1,\'svp_proc_parcelwork\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_parcelwork \@run_date
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_parcelwork\' and seq = 1 and start_date=\@now
if \@\@error = 0
begin
 select 'Executing svp_proc_manifest', getdate()
 set \@now=getdate()
 insert into svp_cp..svp_status_run values ( 2,\'svp_proc_manifest\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
 execute svp_proc_manifest \@run_date
 update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_manifest\' and seq = 2 and start_date=\@now
 if \@\@error = 0
 begin
  select 'Executing svp_proc_parcel_linkage_update',getdate()
  set \@now=getdate()
  insert into svp_cp..svp_status_run values ( 3,\'svp_proc_parcel_linkage_update\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
  execute svp_proc_parcel_linkage_update
  update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_parcel_linkage_update\' and seq = 3 and start_date=\@now
  if \@\@error <>0
  begin
   select 'Errors Occurred during svp_proc_parcel_linkage_update execution', getdate()
  end -- eof Errors Occurred during svp_proc_parcel_linkage_update
 end -- eof svp_proc_manifest ran ok
 else
 begin
  select 'Errors Occurred during svp_proc_manifest  execution', getdate()
 end
end -- eof svp_proc_parcelwork ran ok
else
begin
select 'Errors Occurred during svp_proc_parcelwork execution', getdate()
end
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /Msg/ && $sqlError !~ /2601/ && $sqlError !~ /515/){
      print "Errors may have occurred during update...\n\n";

      $sqlError1 = `. /opt/sap/SYBASE.sh
      isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
      use svp_cp
      go
      set clientapplname \'Rollbacking - Canpar_svp_proc_parcel_update--Step 1\'
      go
      waitfor delay "00:10:00" -- Wait for deadlock situation to pass
      go
      declare \@run_date datetime
      select \@run_date = convert(date,max(inserted_on_cons)) from svp_parcel
      select \"Deleting for following date\:\", \@run_date
      delete svp_records where date_inserted >= \@run_date
      delete svp_messages where inserted_on_cons > convert(datetime,convert(date,getdate()))
      delete svp_parcel from svp_parcel where inserted_on_cons >= \@run_date
      go
      exit
      EOF
      `;

      `/usr/sbin/sendmail -t -i <<EOF
      To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
      Subject: Error - Canpar sp_proc_parcel

      Following status was received during sp_proc_parcel that started on $currTime
      $sqlError
      =================
      $sqlError1
      EOF
      `;


      die ("Can not proceed, due to errors");
}


if($sqlError =~ /Inserted Records Count 0.........Updated Records Count 0/){
 `/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com,forourke\@canpar.com
Subject: Status - Canpar sp_proc_parcel

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
 #
 ## To handle the holidays. Use dateadd(dd,2,max... to capture the holidays
 #
 $sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
set clientapplname \'svp_proc_parcel_update--Step 1\'
go
declare \@run_date date
select \@run_date = dateadd(dd,2,max(inserted_on_cons)) from svp_parcel
if convert(date,\@run_date) <= convert(date,getdate())
begin
select \"Running for following date\:\", \@run_date
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 111,\'svp_proc_parcelwork-holiday\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_parcelwork \@run_date
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_parcelwork-holiday\' and seq = 111 and start_date=\@now
if \@\@error = 0
begin
 select 'Executing svp_proc_manifest', getdate()
 set \@now=getdate()
 insert into svp_cp..svp_status_run values ( 222,\'svp_proc_manifest-holiday\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
 execute svp_proc_manifest \@run_date
 update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_manifest-holiday\' and seq = 222 and start_date=\@now
 if \@\@error = 0
 begin
  select 'Executing svp_proc_parcel_linkage_update',getdate()
  set \@now=getdate()
  insert into svp_cp..svp_status_run values ( 333,\'svp_proc_parcel_linkage_update-holiday\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
  execute svp_proc_parcel_linkage_update
  update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_parcel_linkage_update-holiday\' and seq = 333 and start_date=\@now
  if \@\@error <>0
  begin
   select 'Errors Occurred during svp_proc_parcel_linkage_update execution', getdate()
  end -- eof Errors Occurred during svp_proc_parcel_linkage_update
 end -- eof svp_proc_manifest ran ok
 else
 begin
  select 'Errors Occurred during svp_proc_manifest  execution', getdate()
 end
end -- eof svp_proc_parcelwork ran ok
else
begin
select 'Errors Occurred during svp_proc_parcelwork execution', getdate()
end
--execute svp_proc_parcel_deltermupdation
end -- date check end
go
exit
EOF
`;

}

`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com,forourke\@canpar.com
Subject: Status - Canpar sp_proc_parcel

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;


if($sqlError =~ /Msg/ && $sqlError !~ /2601/ && $sqlError !~ /515/){
      print "Errors may have occurred during update...\n\n";

      $sqlError1 = `. /opt/sap/SYBASE.sh
      isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
      use svp_cp
      go
      set clientapplname \'Rollbacking - Canpar_svp_proc_parcel_update--Step 1\'
      go
      declare \@run_date date
      select \@run_date = convert(date,max(inserted_on_cons)) from svp_parcel
      select \"Deleting for following date\:\", \@run_date
      delete svp_records where date_inserted >= \@run_date
      delete svp_messages where inserted_on_cons > convert(datetime,convert(date,getdate()))
      delete svp_parcel from svp_parcel where inserted_on_cons >= \@run_date
      go
      declare \@now datetime
      set \@now=getdate()
      insert into svp_cp..svp_status_run values ( 444,\'svp_proc_parcel_deltermupdation\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
      execute svp_proc_parcel_deltermupdation
      update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_proc_parcel_deltermupdation\' and seq = 444 and start_date=\@now
      go
      exit
      EOF
      `;

      `/usr/sbin/sendmail -t -i <<EOF
      To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
      Subject: Error - Canpar sp_proc_parcel

      Following status was received during sp_proc_parcel that started on $currTime
      $sqlError
      =======================
      $sqlError1

      EOF
      `;

      die ("Can not proceed, due to errors");
}

$currTime = localtime();
print "Canpar svp_proc_parcelwork FinTime: $currTime\n";


#}# End of if
#########
###Executing url for parcel batch###
#########
$currTime = localtime();
print "Start svp_parcel_url_execution_cp: $currTime \n";

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 4,\'svp_parcel_url_execution_cp\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
go
exit
EOF
`;
system("/opt/sap/cron_scripts/svp_parcel_url_execution_cp.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_url_execution_cp.logi 2>&1");

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
select \@now = max(start_date) from svp_cp..svp_status_run where  job_name=\'svp_parcel_url_execution_cp\' and seq = 4
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_parcel_url_execution_cp\' and seq = 4 and start_date=\@now
go
exit
EOF
`;

print "Start svp_parcel_del_eval_url_execution_cp: $currTime \n";

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 5,\'svp_parcel_del_eval_url_execution_cp\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
go
exit
EOF
`;

`/opt/sap/cron_scripts/svp_parcel_del_eval_execution_cp.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_del_eval_execution_cp.log`;

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
select \@now = max(start_date) from svp_cp..svp_status_run where  job_name=\'svp_parcel_del_eval_url_execution_cp\' and seq = 5
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_parcel_del_eval_url_execution_cp\' and seq = 5 and start_date=\@now
go
exit
EOF
`;


print "Start svp_parcel_exp_del_eval_url_execution_cp: $currTime \n";

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 6,\'svp_parcel_exp_del_eval_url_execution_cp\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
go
exit
EOF
`;

`/opt/sap/cron_scripts/svp_parcel_del_exp_eval_execution_cp.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_del_exp_eval_execution_cp.log`;

$sqlError2 = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
select \@now = max(start_date) from svp_cp..svp_status_run where  job_name=\'svp_parcel_exp_del_eval_url_execution_cp\' and seq = 6
update svp_cp..svp_status_run set end_date=getDate(), status=\'Completed\' where  job_name=\'svp_parcel_exp_del_eval_url_execution_cp\' and seq = 6 and start_date=\@now
go
exit
EOF
`;

#}# AA  End of If

#Execute source_of_failure in the end...

`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: Source of failure proc about to begin.

Check execution plan.

EOF
`;


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
declare \@now datetime
set \@now=getdate()
insert into svp_cp..svp_status_run values ( 7,\'svp_proc_source_failure\',\@now,\'01/01/1900',\'start\',getDate(),getDate())
execute svp_proc_source_failure
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
