#!/usr/bin/perl -w

###################################################################################
#Script:   This script checks the database consistency through sp_dbcc_runcheck   #
#          If any error are found, send emal to DBA's                             #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date	Feb 21, 06	Name Ahsan Ahmed	Description                       #
#---------------------------------------------------------------------------------#
#12/30/03	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: dbcc_check.pl CPDB1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Execute dbcc_runcheck based on database name provided

print "\n###Running runcheck on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating runcheck At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server <<EOF 2>&1
set command_status_reporting on
go
sp_dbcc_runcheck "$database"
go
select "Scan of $database finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
   if ($error =~ /Msg/ || $error ne ''){
      print "Messages From Database runcheck Process...\n";
      print "$error\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: DBCC RUNCHECK: $database

$error
EOF
`;
   }#end of if messages received


#The Following line marks the end in the log file, leave at the bottom of this file
print "************************\nEnd of log at ".localtime()." ******************************\n\n";
