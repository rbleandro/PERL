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
#11/01/07      Ahsan Ahmed      Modified
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

require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute UPSResultSet


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use cpscan
go
truncate table UPSResult     
go   
exec UPSResultSet     
go   
exit
EOF
`;
if ($sqlError =~ /Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: aarain\@canpar.com,alex_vasilenco\@canpar.com
Subject: UPSResultSet completed at $finTime

$sqlError
EOF
`;
}
