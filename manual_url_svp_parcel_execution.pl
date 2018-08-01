#!/usr/bin/perl 

###################################################################################
#Script:   This script executes a URL web based program remotely on cpmycanpar    #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jun 11,08	Amer Khan       Originally created                                #
#                                                                                 #
#                                                                                 #
###################################################################################

open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
#        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Setting Time
$currDate=localtime();
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "Mounting folder, if it is already not done yet...\n";

$mount_msgs = `sudo mount cpmycanpar2.canpar.com:/opt/tomcat/logs  /opt/sybase/eput_eval_mount 2>&1`;

print "Any mounting messages, already mounted messages can be ignored:\n\n $mount_msgs\n";

print "SVP URL Execution StartTime: $currTime, Hour: $startHour, Min: $startMin\n";


`elinks \"http\:\/\/10.3.1.30\/sp\/batchParcelEvaluation.do\?tokenId\=canpar\&token\=M985NRKHVKWuet26QvsMkQbP6mY\=\" \> \/tmp\/out.out 2>&1`;

