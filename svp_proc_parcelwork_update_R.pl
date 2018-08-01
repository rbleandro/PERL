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
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "svp_proc_parcelwork StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
set replication off
go
execute svp_proc_parcelwork_new 3  
go
select "executing parcelwork update now:", getdate()   
go   
execute svp_proc_parcelwork_update    
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - updating sp_proc_parcelwork

Following status was received during sp_proc_parcelwork that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "svp_proc_parcelwork FinTime: $currTime\n";

###Executing url for parcel batch###
`/opt/sybase/cron_scripts/svp_parcel_url_execution.pl > /opt/sybase/cron_scripts/cron_logs/svp_parcel_url_execution.log`;


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "svp_proc_parcel StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
set replication off
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

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - sp_proc_parcel

Following status was received during sp_proc_parcel that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "svp_proc_parcel FinTime: $currTime\n";


