#!/usr/bin/perl -w

##############################################################################
#Description: Script to capture current running processes on Sybase instance #
#             for troubleshooting purposes                                   #
#                                                                            #
#Author:	Rafael Leandro					     							 #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#June 11 2018	Rafael Leandro 	Originally created                           #
#                                                                            #
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


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep mon_current_processes.pl|grep -v grep|grep -v $my_pid|grep -v "vim mon_current_processes.pl"|grep -v "less mon_current_processes.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "Capture Running processes StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -b -n<<EOF 2>&1
use master
go
exec sp_getRunningProcesses
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: ERROR - Capture Running processes

Following status was received during Capture Running processes that started on $currTime\n\n
$sqlError
EOF
`;
}
$currTime = localtime();
print "Capture Running processes FinTime: $currTime\n";

