#!/usr/bin/perl -w

###################################################################################
#Script:   This script runs reorg in different databases. All the sql and logic is#
#          included in this script. Script is supposed to work with all databases.#
#                                         					  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#01/09/04	Amer Khan	Originally created                                #
#01/19/04	Amer Khan	Modified to work with all dbs			  #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: run_reorg_compact.pl CPDB1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Execute reorg command based on database name provided

print "\n###Running reorg compact on Database:$database in Server:$server on Host:".`hostname`."###\n";


print "***Initiating reorg At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use $database
go
set nocount on
go
declare \@table_id int, \@table_id_next int, \@table_name varchar(30)
select \@table_id = min(id) from sysobjects where type = \"U\"
select \"Starting Reorg process in $database at \" + convert(varchar,getdate(),109)
while(\@table_id <> \@table_id_next)
BEGIN
select \@table_name = object_name(\@table_id)
if exists(select 1 from sysobjects where type=\"U\" and id = \@table_id and ((sysstat2 \& 57344) = 16384 or (sysstat2 \& 57344) = 32768))
BEGIN
if not exists (select 1 from sysobjects so, sysattributes sy where so.name = sy.object_cinfo and so.name = \@table_name)
BEGIN
select \"\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*Running reorg compact for \" \+ \@table_name \+ \" at \" \+ convert(varchar, getdate(),109) \+ \"\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\"
exec (\"reorg compact \" \+ \@table_name)
select \"\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*Completed reorg compact for \" \+ \@table_name \+ \" at \" \+ convert(varchar, getdate(),109) \+ \"\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\"
END
ELSE
select "Skipping Proxy table: " \+ \@table_name \+ "..."
END
else
select \"This table does not have appropriate locking scheme for reorg\: \" \+ \@table_name
select \@table_id_next = \@table_id
set rowcount 1
select \@table_id = id from sysobjects where type = \"U\" and id > \@table_id_next
set rowcount 0
END
go
exit
EOF
`;
   if ($sqlError =~ /Msg/ || $sqlError ne ''){
      print "Messages From Database reorg Process...\n";
      print "$sqlError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: REORG: $database

Following status was received after $database reorg on \`date\`
$sqlError
EOF
`;
   }#end of if messages received





#The Following line marks the end in the log file, leave at the bottom of this file
print "************************End of log at ".localtime()." ******************************\n\n";
