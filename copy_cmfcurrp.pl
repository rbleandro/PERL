#!/usr/bin/perl -w

##############################################################################
#Script:   This script will run import_costing_data procedure and added      #
#          email for DBA's                                                   #
#Author:    Ahsan ahmed                                                      #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2004/12/06   Ahsan Ahmed       Originally created                           #
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";



$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -Ps9b2s3 -Scpsybtest -b -n<<EOF 2>&1
use cmf_data
go
truncate table cmf_data_dev..cmfcurrp_backup
go
insert cmf_data_dev..cmfcurrp_backup select * from cmfcurrp
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: It was done at $finTime 

$sqlError
EOF
`;
