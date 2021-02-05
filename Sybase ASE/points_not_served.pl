#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates points_not_served table in cmf_data            #
#                                                                            #
#Author:    Ahsan Ahmed							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2006/12/11	Ahsan Ahmed 	Originally created                           #
#                                                                            #
###################################################################################

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

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
execute points_not_served_refresh
go
exit
EOF
`;
print $sqlError."\n";


if($sqlError =~ /no|not/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating points_not_served

Following status was received during updating points_not_served that started on $currTime
$sqlError
EOF
`;
}
`echo 0 > /tmp/points_not_served_status`;
$currTime = localtime();
print "FinTime: $currTime\n";
