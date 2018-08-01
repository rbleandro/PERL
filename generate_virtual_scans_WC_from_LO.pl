#!/usr/bin/perl -w

##############################################################################
#Script:   This script generates arr scans for terminal 420 in cpscan        #
#          tttl_ev_event every 15 min                                        #
#                                                                            #
#Author:   Amer Khan                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Aug 11 2016	Amer Khan	Originally Created                           #
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

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep generate_virtual_scans_WC_from_LO.pl|grep -v grep|grep -v $my_pid|grep -v "vim generate_virtual_scans_WC_from_LO.pl"|grep -v "less generate_virtual_scans_WC_from_LO.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use cpscan
go
exec virtual_WC_from_LO
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
Subject: Error: generate_virtual_scans_WC_from_LO at $finTime

$sqlError
EOF
`;
}
