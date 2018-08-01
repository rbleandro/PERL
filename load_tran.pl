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
#02/23/06       Ahsan Ahmed     Last modified                                     #              
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
if ($database eq "cpscan"){

print "\n###Killing any users still logged into cpscan###\n\n";
`/opt/sybase/cron_scripts/kill_processes.pl CPDB1 cpscan`;

print "\n###Loading Transaction For:$database from Server:$server on Host:".`hostname`."###\n\n";

print "***Initiating Load At:".localtime()."***\n\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
load transaction cpscan from "compress::/opt/sybase/db_backups/stripe17/$file_name.tran"
stripe on "compress::/opt/sybase/db_backups/stripe18/$file_name.tran"
stripe on "compress::/opt/sybase/db_backups/stripe19/$file_name.tran"
go
if \@\@error=0
select "Load of $database tran finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

print "$loadError\n";
#check for errors and then start ftp...
if($loadError =~ /complete/){
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

$endDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($endDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject:TRANSACTION LOAD: $database

#Following status was received after $database load that started on $currTime
#*******************************************
#$database transaction load completed successfully in $totalHours Hours and $totalMins Minutes
#*******************************************
#DATED: \`date\`
#EOF
#`;

#Copy files over to the daily archive folder
#$cpError = `cp /opt/sybase/db_backups/stripe11/$tranFile.tran1 /opt/sybase/db_backups/stripe12/$tranFile.tran2 /opt/sybase/db_backups/$currDay/`;

print "Copy of $database tran logs To Archive Messages...\n\n$cpError\n\n";

}else{
   print "Load Failed, check log for more details\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = cpscan

if ($database eq "rev_hist"){

print "\n###Killing any users still logged into rev_hist###\n\n";
$sh_error = `/opt/sybase/cron_scripts/kill_processes.pl CPDATA2 rev_hist`;
print $sh_error;

print "\n###Loading Transaction For:$database from Server:$server on Host:".`hostname`."###\n\n";

print "***Initiating Load At:".localtime()."***\n\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
load transaction $database from "compress::/opt/sybase/db_backups/stripe11/$tranFile.tran1"
go
if \@\@error=0
select "Load of $database tran finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
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

$endDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($endDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}
   
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com 
#Subject:TRANSACTION LOAD: $database
#
#Following status was received after $database load that started on $currTime
#*******************************************
#$database transaction load completed successfully in $totalHours Hours and $totalMins Minutes
#*******************************************
#DATED: \`date\`
#EOF
#`;

#Copy files over to the daily archive folder
$cpError = `cp /opt/sybase/db_backups/stripe11/$tranFile.tran1 /opt/sybase/db_backups/$currDay/`;

print "Copy of $database tran logs To Archive Messages...\n\n$cpError\n\n";

}else{
   print "Load Failed, check log for more details\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = rev_hist

if ($database eq "cmf_data"){

print "\n###Killing any users still logged into cmf_data###\n\n";
$sh_error = `/opt/sybase/cron_scripts/kill_processes.pl CPDATA2 cmf_data`;
print $sh_error;

print "\n###Loading Transaction For:$database from Server:$server on Host:".`hostname`."###\n\n";

print "***Initiating Load At:".localtime()."***\n\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
load transaction $database from "compress::/opt/sybase/db_backups/stripe11/$tranFile.tran1"
go
if \@\@error=0
select "Load of $database tran finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
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

$endDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($endDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}
   
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject:TRANSACTION LOAD: $database

#Following status was received after $database load that started on $currTime
#*******************************************
#$database transaction load completed successfully in $totalHours Hours and $totalMins Minutes
#*******************************************
#DATED: \`date\`
#EOF
#`;

#Copy files over to the daily archive folder
$cpError = `cp /opt/sybase/db_backups/stripe11/$tranFile.tran1 /opt/sybase/db_backups/$currDay/`;

print "Copy of $database tran logs To Archive Messages...\n\n$cpError\n\n";

}else{
   print "Load Failed, check log for more details\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = cmf_data

