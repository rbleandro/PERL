#!/usr/bin/perl

###################################################################################
#Script:   This script loads different (Transaction Load) databases. All the sql  #
#          and logic is included in this script. Script is supposed to work with  #
#          all databases. Also, added email for DBA's                             #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/23/03	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV < 1){
   print "Usage: load_tran.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];
$startDay = $ARGV[2];
$startHour = $ARGV[3];
$startMins = $ARGV[4];
$file_name = $ARGV[5];

$current = localtime();

use POSIX qw(strftime);
$currDay = lc(strftime "%A", localtime);  # Record the current day for placing tran in the right folders

#Set the name of the tran file based on incoming params
$tranFile = $database."_".$startHour."_".$startMins;

#Execute load command based on database name provided

print "\n###Killing any users still logged into rev_hist###\n\n";
$sh_error = `/opt/sybase/cron_scripts/kill_processes.pl CPDATA2 rev_hist`;
print $sh_error;

print "\n###Loading Transaction For:$database from Server:$server on Host:".`hostname`."###\n\n";

print "***Initiating Load At:".localtime()."***\n\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
load transaction $database from "compress::/opt/sybase/db_backups/stripe11/$tranFile.tran1"
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /LOAD is complete/){
   print "Transaction Load was successful at ".localtime()."\n\n";
   print "Bringing Database To standby access...\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
online database $database for standby_access
go
exit
EOF
`;

print $onlineError."\n";

}else{
   print "Load Failed, check log for more details\!\n";
   print $loadError."\n";
}#eof of failure

