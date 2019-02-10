#!/usr/bin/perl

###################################################################################
#Script:   This script runs recalc_cost. All the sql and logic is built in.       #
#                                         					  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#11/12/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage: run_recalc_cost.pl CPDATA1\n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];

#if (1==2){ #dont run
print "***************Start Recalc Process NOW**************".localtime()."\n";

print "Truncate and Drop existing temp tables for a new recalc\n";
`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/drop_cost_calc_temp_tables.sql`;

#Clear tempdb tran
#`isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF
dump tran tempdb with truncate_only
go
exit
EOF
`;

print "Now running sql 1-5...".localtime()."\n";
$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql1 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql2 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql3 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql4 &
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 -i/opt/sybase/cron_scripts/sql/run_recalc_cost.sql5 &
`;

$dbsqlOut1 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql1`;

$dbsqlOut2 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql2`;

$dbsqlOut3 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql3`;

$dbsqlOut4 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql4`;

$dbsqlOut5 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql5`;

$dbsqlOut6 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql6`;

$dbsqlOut7 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql7`;

$dbsqlOut8 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql8`;

$dbsqlOut9 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql9`;

$dbsqlOut10 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql10`;

$dbsqlOut11 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql11`;

$dbsqlOut12 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql12`;

$dbsqlOut13 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql13`;

$dbsqlOut14 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql14`;

$dbsqlOut15 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql15`;

$dbsqlOut16 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql16`;

$dbsqlOut17 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql17`;

$dbsqlOut18 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql18`;

$dbsqlOut19 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/run_recalc.sql19`;

$dbsqlOut20 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/truncate_calc_cost.sql`;

$dbsqlOut21 = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/cost_analysis/populate_calc_cost.sql`;








#The Following line marks the end in the log file, leave at the bottom of this file
print "************************End of Recalc Process at ".localtime()." ******************************\n\n";
