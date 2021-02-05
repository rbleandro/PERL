#!/usr/bin/perl -w

##############################################################################
#Script:   This script  moves ma tables data from ma tables in lm_stage to   #
#          lmscan every 5min                                                 #
#                                                                            #
#Author:   Amer Khan                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#May 31	2015	Amer Khan	Originally Created                           #
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
$isProcessRunning =`ps -ef|grep sybase|grep import_ma_data.pl|grep -v grep|grep -v $my_pid|grep -v "vim import_ma_data.pl"|grep -v "less import_ma_data.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver <<EOF 2>&1
use lmscan
go
exec ds_import_ma_data_from_stage
go   
exit
EOF
`;

print "Any message from the proc execution...\n $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/ || $sqlError =~ /error/i){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: Error: import_ma_data at $finTime

$sqlError
EOF
`;
}
