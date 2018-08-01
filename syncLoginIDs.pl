#!/usr/bin/perl -w

###################################################################################
#Script:   This script synchronizes login ids from CPDATA1 to CPDATA2             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#08/20/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
#if ($#ARGV != 1){
#   print "Usage: dbcc_check.pl CPDB1 cpscan \n";
#   die "Script Executed With Wrong Number Of Arguments\n";
#}

#Setting Sybase environment is set properly
require "/opt/sybase/cron_scripts/set_sybase_env.pl";

print "***Initiating backup of original syslogins At:".localtime()."***\n";
$bup_syslogins = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA2 -b -n<<EOF 2>&1
use tempdb
go
drop table cp_syslogins
go
select * into cp_syslogins from master..syslogins
if \@\@error != 0
BEGIN
goto endNow
END
use master
begin tran
delete master..syslogins where name <> 'sa'
if \@\@error != 0
rollback
else
commit
endNow:
go
exit
EOF
`;
if ($bup_syslogins =~ /Msg|Level|State|Cannot/){
print "Messages from dropping cp_syslogins from tempdb creating a new one from master syslogins and deleting data from master syslogins:\n$bup_syslogins\n\n";
die "Died due to failure!!\n";
}

$bcp_CPDATA1_syslogins = `bcp master..syslogins out /tmp/CPDATA1_syslogins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -c`;

print "BCP out messages from CPDATA1...:\n$bcp_CPDATA1_syslogins\n";

$bcp_CPDATA2_syslogins = `bcp master..syslogins in /tmp/CPDATA1_syslogins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA2 -c -F2`;
 
print "BCP in messages from CPDATA2...:\n$bcp_CPDATA2_syslogins\n";

#The Following line marks the end in the log file, leave at the bottom of this file
print "************************\nEnd of log at ".localtime()." ******************************\n\n";
