#!/usr/bin/perl -w

##############################################################################
#Script:   This script sends daily logs of all cron jobs to log server       #
#                                                                            #
#Author:   Amer Khan                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#01/27/09       Amer Khan       Created                                      #
##############################################################################


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";
$mon=$mon+1;#Month perl starts with 0, go figure...
$year += 1900;

$dirname = "/opt/sybase/cron_scripts/cron_logs";

opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";

# Consider files with .csv extension only
@file_array = readdir(DIR);

`/usr/bin/logger "==== Start of Sybase Production Daily Log ====" `;

foreach $filename (@file_array){
next if (-d "$dirname/$filename");

if ( (-C "$dirname/$filename") <= 1){
print "Working on $dirname/$filename\n";

`/usr/bin/logger "==== Job Log Start ====" `;
`/usr/bin/logger -f $dirname/$filename `;
`/usr/bin/logger "==== Job Log End ====" `;

}

} #eof file array

`/usr/bin/logger "==== End of Sybase Production Daily Log ====" `;

`cat /dev/null > /opt/sybase/cron_scripts/cron_logs/monitor_errorlog_CPDB1.log`;

