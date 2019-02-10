#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates points_ranges table in cmf_data               #
#                                                                            #
#Author:   Ahsan Ahmed							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2010/1/08	Ahsan_Ahmed	Originally created                           #
#                                                                            #
#2010/1/08      Ahsan Ahmed      Modified                                     #
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
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}
else
{
   $standbyserver = "CPDB2";
}


#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

#$checkFlag = `cat /tmp/points_ranges_status`;
$sqlError = ""; # Initialize Var

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go     
set replication off
go         
execute reset_points_ranges_minor
go      
exit        
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject:   $prodserver ERROR - updating points_ranges_minor

Following status was received during updating points_ranges_minor that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "FinTime on $prodserver: $currTime\n";

#$sqlError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$standbyserver -b -n<<EOF 2>&1
#use cmf_data
#go
#execute reset_points_ranges_minor
#go
#exit
#EOF
#`;
#print $sqlError."\n";

#if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i){
#      print "Errors may have occurred during update_minor...\n\n";
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: $standbyserver  ERROR - updating points_ranges_minor
#
#Following status was received during updating points_ranges_minor that started on $currTime
#$sqlError
#EOF
#`;
#}
$currTime = localtime();
print "FinTime on $standbyserver: $currTime\n";

