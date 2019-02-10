#!/usr/bin/perl -w

##############################################################################
#Script:   This script does what gentor used to do.			     #
#                                                                            #
#Author:	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#Apr 8 2016	Amer Khan	Created					     #
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
$isProcessRunning =`ps -ef|grep sybase|grep generate_overhead_scan_events.pl|grep -v grep|grep -v $my_pid|grep -v "vim generate_overhead_scan_events.pl"|grep -v "less generate_overhead_scan_events.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Uoverhead_scan_user -P\`/opt/sap/cron_scripts/getpass.pl overhead_scan_user\` -S$prodserver <<EOF 2>&1
use sort_data
go    
exec generate_overhead_scan_events
go 
exit
EOF
`;

if ($sqlError =~ /Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,rtoyota\@canpar.com
Subject: Errors - generate_overhead_scan_events at $finTime

$sqlError
EOF
`;
}

`/usr/sbin/sendmail -t -i <<EOF
To: rtoyota\@canpar.com
Subject: Msgs - generate_overhead_scan_events at $finTime

$sqlError
EOF
`;

$finTime = localtime();
print "Time Finished: $finTime\n";
