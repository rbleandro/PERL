#!/usr/bin/perl -w

##############################################################################
#Script:   This script loads data into fedexresult table for last two        #
#          weeks every night                                                 #
#                                                                            #
#Author:   Ahsan Ahmed
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
$server = $ARGV[0];

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute FedExResultSet


$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server <<EOF 2>&1
use cpscan
go
truncate table FedExResult
go   
exec FedExResultSet
go   
exit
EOF
`;
if ($sqlError =~ /Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: ahsan_ahmed\@canpar.com
Subject: FedExResultSet completed at $finTime

$sqlError
EOF
`;
}
