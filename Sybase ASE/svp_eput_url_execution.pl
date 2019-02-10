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

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
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

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon += 1;

$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);
$min=sprintf('%02d',$min);
$hour=sprintf('%02d',$hour);
$sec=sprintf('%02d',$sec);

$date_flag = "$mon-$mday-$year $hour:$min:$sec";
#$date_flag = '02/21/2012 12:48:53 AM';
print "Date to check from : $date_flag \n";

print "SVP URL Execution StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

`elinks \"http\:\/\/www.canpar.com\/sp\/batchEputEvaluation.do\?tokenId\=canpar\&token\=M985NRKHVKWuet26QvsMkQbP6mY\=\" \> \/tmp\/out.out 2>&1`;
#sleep(50);


while (1==1){
unless (-e "/tmp/svp_e_completed"){
sleep(5);
$monitorOutput = `/opt/sap/cron_scripts/svp_eput_url_monitor.pl \"$date_flag\"`;
}else{
`rm /tmp/svp_e_completed`;
last;
}
}


