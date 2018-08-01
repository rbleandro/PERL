#!/usr/bin/perl -w

##############################################################################
#Description: This script runs the proc parcelwork procedures                #
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Jul 31 2008	Amer Khan 	Originally created                           #
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
$isProcessRunning =`ps -ef|grep sybase|grep svp_proc_parcelwork_update.pl|grep -v grep|grep -v $my_pid|grep -v "vim svp_proc_parcelwork_update.pl"|grep -v "less svp_proc_parcelwork_update.pl"`;

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
use cmf_data
go
set nocount on
go   
select datediff(dd,max(inserted_on_cons),'$today') from svp_parcel_work
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
use cmf_data
go
set clientapplname \'svp_proc_parcel_update--Step 1\'     
go    
declare \@run_date date          
select \@run_date = dateadd(dd,1,max(inserted_on_cons)) from svp_parcel_work        
select \"Running for following date\:\", \@run_date     
execute svp_proc_parcelwork \@run_date
go
select "executing parcelwork update now:", getdate()   
go   
execute svp_proc_parcelwork_update    
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /Inserted Records Count 0.........Updated Records Count 0/){
`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com,forourke\@canpar.com
Subject: Status - sp_proc_parcel step1

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
#
## To handle the holidays. Use dateadd(dd,2,max... to capture the holidays
#
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
set clientapplname \'svp_proc_parcel_update--Step 1\'
go
declare \@run_date date
select \@run_date = dateadd(dd,2,max(inserted_on_cons)) from svp_parcel_work
if convert(date,\@run_date) <= convert(date,getdate())
begin
select \"Running for following date\:\", \@run_date
execute svp_proc_parcelwork \@run_date
select "executing parcelwork update now:", getdate()
execute svp_proc_parcelwork_update
end
go
exit
EOF
`;

}

`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com,forourke\@canpar.com
Subject: Status - sp_proc_parcel step1

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;


if($sqlError =~ /Msg/ && $sqlError !~ /2601/ ){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Error - sp_proc_parcel Step 1

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
}

$currTime = localtime();
print "svp_proc_parcelwork FinTime: $currTime\n";

while ($startHour ne '23' && $startHour ne '00' && $startHour ne '01' && $startHour ne '02' && $startHour ne '03' && $startHour eq '04'){
print "start hour not there yet: $startHour \n";
sleep(600);
}
print "It is time to run url: $startHour \n";

#}# End of if
#########
###Executing url for parcel batch###
`/opt/sap/cron_scripts/svp_parcel_url_execution.pl > /opt/sap/cron_scripts/cron_logs/svp_parcel_url_execution.log`;

#}# AA  End of If
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "svp_proc_parcel StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
set clientapplname \'svp_proc_parcel_update--Step 2\'    
go    
execute svp_proc_parcelwork_move   
go    
execute svp_proc_parcel_linkage_update   
go    
execute svp_proc_parcel_update_split    
go     
execute svp_proc_parcel_update_mfst    
go    
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no|not/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com,aahmed\@canpar.com,forourke\@canpar.com
Subject: Status - sp_proc_parcel step2

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com
Subject: Status - sp_proc_parcel step2

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
}

if($sqlError =~ /Msg/ && $sqlError !~ /2601/ ){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Error - sp_proc_parcel Step 2

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
}

$currTime = localtime();
print "svp_proc_parcel FinTime: $currTime\n";

`touch /tmp/svp_parcel_proc_done`;
