#!/usr/bin/perl -w

##############################################################################
#Description: This script runs the proc svp_proc_parcelwork_missed_pickups   #
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Aug 13 2008	Amer Khan 	Originally created                           #
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

#Setting Sybase environment is set properly

#require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "svp_proc_parcelwork StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
execute svp_proc_parcelwork_missed_pickups
go
select "executing svp_proc_parcelwork_missed_pickups now:", getdate()   
go   
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - svp_proc_parcelwork_missed_pickups

Following status was received during svp_proc_parcelwork_missed_pickups that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "svp_proc_parcelwork_missed_pickups FinTime: $currTime\n";

