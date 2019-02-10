#!/usr/bin/perl -w

###################################################################################
#Script:   This script runs update stats in different databases. All the sql and  #
#          logic is included in this script. Script is designed to work with all  #
#          databases                                                              #
#                                         					  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#01/15/04	Amer Khan	Originally created                                #
#01/19/04	Amer Khan	Modified to run for all dbs			  #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: run_update_stats.pl CPDB1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Initialize vars
$current = localtime();
$startHour = sprintf('%02d',((localtime())[2]));

#Execute update stats command based on database name provided

print "\n###Running update stats on Database:$database in Server:$server on Host:".`hostname`."###\n";


print "***Initiating update stats At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use $database
go
set nocount on
go
declare \@table_id int, \@table_id_next int, \@table_name varchar(30)
select \@table_id = min(id) from sysobjects where type = \"U\" and (sysstat2 \& 1024) <> 1024
select \"Starting update stats process in $database at \" + convert(varchar,getdate(),109)
while(\@table_id <> \@table_id_next)
BEGIN
select \@table_name = object_name(\@table_id)
select "\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*Running Update Statistics on " + \@table_name + " at " + convert(varchar, getdate(),109) + "\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*"
exec ("update index statistics " + \@table_name)
select "\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*Completed Update Statistics on " + \@table_name + " at " + convert(varchar, getdate(),109) + "\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*"
select \@table_id_next = \@table_id
set rowcount 1
select \@table_id = id from sysobjects where type = \"U\" and id > \@table_id_next and (sysstat2 \& 1024) <> 1024
set rowcount 0
END
go
exit
EOF
`;
print $sqlError."\n";
$currHour = sprintf('%02d',((localtime())[2]));
$currMins = sprintf('%02d',((localtime())[1]));
$totalHour = $currHour - $startHour;

   if ($sqlError =~ /error/i || $sqlError =~ /critically/i){
      print "Messages From Database update stats Process...\n";
      print "$sqlError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - UPDATE STATS: $database

Following status was received after $database update statistics on $current
---------------------------------------------------------------------------

$sqlError

*********************
Update Stats ended at \`date\`
*********************
EOF
`;
   }else{#end of if messages received
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: UPDATE STATS: $database

******************************************************************************
Update Stats for $database completed successfully in $totalHour Hours and $currMins Minutes
******************************************************************************
EOF
`;
}

#The Following line marks the end in the log file, leave at the bottom of this file
print "************************End of log at ".localtime()." ******************************\n\n";
