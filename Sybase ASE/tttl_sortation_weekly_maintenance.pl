#!/usr/bin/perl -w


#Script:   This script delete rows from tttl_sortation table every Sunday
#          that are less than 60 days old
#
#Author:   Ahsan Ahmed
#Revision:
#Date           Name            Description
#--------------------------------------------------------------------------
#
#02/09/2012      Ahsan Ahmed      Created
#01/10/2020      Rafael 	      Changed the execution user to cronmpr for security reasons

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

require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute  tttl_sortation_weekly_maintenace

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -w300 <<EOF 2>&1
use cpscan
go
execute tttl_sortation_maintenance
go
exit
EOF
`;
print $sqlError."\n";

 if ($sqlError =~ /Error/i || $sqlError =~ /no/i || $sqlError =~ /message/i){
      print "Messages From tttl_sorattion_maintenace...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: tttl_sortation_maintenace errors  will not be processed!!

$sqlError
EOF
`;
}else{
#...
#
}
