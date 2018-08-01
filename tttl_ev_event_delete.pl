#!/usr/bin/perl -w

##############################################################################
#Script:   This script will delete tttl_ev_event specefic data every day     #
#                                                                            #
#                                                                            #
#Author:   Ahsan Ahmed                                                       #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 4   2013 Ahsan Ahmed	Originally Created                           #
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


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use cpscan
go
exec ev_event_delete  
go   
exit
EOF
`;

print "Any message from the proc execution...\n $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: Delete tttl_ev_event  at $finTime

$sqlError
EOF
`;
}
