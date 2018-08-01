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

#Execute liberty_update


$sqlError = `. /opt/sybase/SYBASE.sh
isql -Urandy_ogilvie -Pcanpar -SCPDB2 -b -n<<EOF 2>&1
use cmf_data
go   
exec import_costing_data null, 14, '2006-12-01 00:00', '2006-12-31 23:59:59', 2, 'all'
go   
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Import costing data job was done at $finTime 

$sqlError
EOF
`;
