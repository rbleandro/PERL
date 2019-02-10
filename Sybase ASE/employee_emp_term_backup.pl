#!/usr/bin/perl 

###################################################################################
#Script:   This script is reporting the startup and completion of url execution   #
#          for eput batch evaluation java program                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jul 21,08	Amer Khan       Originally created                                #
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

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon += 1;
$min -= 1; #Start from the previous minute

$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);

$empFile = "employee_$year-$mon-$mday.dat";

$emp_termFile = "emp_term_$year-$mon-$mday.dat";

$sqlError = `. /opt/sybase/SYBASE.sh
bcp cpscan..employee out /opt/sybase/tmp/cpscan/$empFile -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"
bcp cpscan..employee_terminal out /opt/sybase/tmp/cpscan/$emp_termFile -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"
`;

