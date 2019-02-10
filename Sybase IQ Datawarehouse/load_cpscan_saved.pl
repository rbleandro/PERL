#!/usr/bin/perl -w

###################################################################################
#Script:   This script keeps track of the database growth and percent increase in #
#          db size from the last reading taken                                    #
#                                                                                 #
#Note:     This script can be used with any database, but you have to have a table#
#          called db_growth_record in the database where it is being executed     #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: db_growth.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";

#Store inputs
$server = $ARGV[0];
$day = $ARGV[1];

#if (1==2){
print "\n###Running cpscan load to cpiq on Host:".`hostname`."###\n";
#*************************Drop and recreate temp tables********************************#
$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -b -n -i/opt/sybase/cron_scripts/sql/iq_drop_tempTables_in_ase.sql`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Level/){      
      print "Messages From cpscan IQ Load Error...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: cpscan IQ Load Error: Error in dropping tables

$sqlError
EOF
`;
die "Error in dropping tables, can't continuen\n\n";
}else{
   print "$sqlError\n\n";
}

#******Before creating temp tables, alter the sql to reflect the correct day to retrieve data for*******

print "Setting the sql for day requested...\n";
$sedError = `sed -e s/dd,..,max/dd,-$day,max/ /opt/sybase/cron_scripts/sql/create_temp_tables_for_IQ_load.sql > /tmp/create_temp_tables_for_IQ_load.sql`;

print "Any erorrs from sed... $sedError\n\n";

$sqlError = `isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -b -n -i/tmp/create_temp_tables_for_IQ_load.sql`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Level/){
      print "Messages From cpscan IQ Load Error...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: cpscan IQ Load Error: Error in creating temp tables

$sqlError
EOF
`;
die "Error creating temp tables, can't continue\n\n";
}else{
   print "$sqlError\n\n";
}
#*************************************************************************************#

#Removing all previous data files for inserts and updates
`rm /opt/sybase/bcp_data/cpscan/*`;

#*************************Initiating delete of rows in cpscan tables*************************#
#Set a flag to determine whether it is ok to truncate tables in cpscan_rep which keep deletes from CPDATA1
$no_trunc_del_tables=0;

print "***Initiating BCP FROM ASE for tttl_pa_parcel_deletes At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pa_parcel_deletes out /opt/sybase/bcp_data/cpscan/tttl_pa_del.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA1 -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pa_parcel_deletes...\n";
      print "$bcpError\n";
      $no_trunc_del_tables=1;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pa_parcel_deletes

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pa_parcel_deletes At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pa_delete.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/delete_tttl_pa.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pa_delete.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pa_delete.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pa_delete...\n";
      print "$dbsqlError\n";
      $no_trunc_del_tables=1;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pa_delete

$dbsqlError
EOF
`;
}

print "***Initiating BCP FROM ASE for tttl_ev_event_deletes At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ev_event_deletes out /opt/sybase/bcp_data/cpscan/tttl_ev_del.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA1 -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ev_event_deletes...\n";
      print "$bcpError\n";
      $no_trunc_del_tables=1;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ev_event_deletes

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ev_event_deletes At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ev_delete.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/delete_tttl_ev.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ev_delete.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ev_delete.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ev_delete...\n";
      print "$dbsqlError\n";
      $no_trunc_del_tables=1;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ev_delete

$dbsqlError
EOF
`;
}

if($no_trunc_del_tables == 0){
   #Truncating table
$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDATA1 -w300 <<EOF 2>&1
use cpscan
go
delete tttl_pa_parcel_deletes
go
delete tttl_ev_event_deletes
go
exit
EOF
`;
}

#*************************Initiating Inserts of new rows into cpscan tables*************************#
#if (1==2){
print "***Initiating BCP FROM ASE for driver_stats_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..driver_stats_insert_iq_vw out /opt/sybase/bcp_data/cpscan/driver_stats_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;

if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From driver_stats_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: driver_stats_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for driver_stats_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_driver_stats_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_driver_stats.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_driver_stats_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_driver_stats_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_driver_stats_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_driver_stats_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for truck_stats_insert_iq At:".localtime()."***\n";
#$bcpError = `bcp cpscan..truck_stats_insert_iq_vw out /opt/sybase/bcp_data/cpscan/truck_stats_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;

if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From truck_stats_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: truck_stats_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for truck_stats_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_truck_stats_insert.err") || print "Can't do it\n";
#$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_truck_stats.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_truck_stats_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_truck_stats_insert.err`;
print "$dbsqlOut\n";
$dbsqlError='affected';#***********Remove this to enable load***********
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_truck_stats_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_truck_stats_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for employee_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..employee_insert_iq_vw out /opt/sybase/bcp_data/cpscan/employee_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;

if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From employee_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: employee_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for employee_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_employee_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_employee.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_employee_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_employee_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_employee_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_employee_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_bi_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_bi_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_bi_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_bi_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_bi_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_bi_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_bi_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_bi.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_bi_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_bi_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_bi_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_bi_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_cp_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_cp_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_cp_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_cp_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_cp_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_cp_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_cp_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_cp.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_cp_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_cp_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_cp_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_cp_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ct_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ct_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ct_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ct_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ct_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ct_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ct_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ct.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ct_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ct_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ct_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ct_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dc_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dc_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dc_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dc_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dc_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dc_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dc_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_dc.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dc_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dc_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dc_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dc_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dex_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dex_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dex_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dex_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dex_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dex_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dex_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_dex.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dex_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dex_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dex_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dex_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dp_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dp_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dp_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dp_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dp_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dp_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dp_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_dp.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dp_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dp_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dp_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dp_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dr_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dr_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dr_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dr_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dr_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dr_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dr_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_dr.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dr_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dr_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dr_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dr_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ev_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ev_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ev_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ev_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ev_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ev_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ev_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ev.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ev_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ev_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ev_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ev_insert

$dbsqlError
EOF
`;
}

#sleep(60);
#} #eof dont run
print "***Initiating BCP FROM ASE for tttl_ex_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ex_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ex_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ex_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ex_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ex_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ex_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ex.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ex_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ex_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ex_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ex_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_fl_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_fl_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_fl_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_fl_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_fl_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_fl_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_fl_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_fl.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_fl_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_fl_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_fl_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_fl_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_hc_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_hc_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_hc_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_hc_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_hc_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_hc_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_hc_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_hc.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_hc_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_hc_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_hc_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_hc_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_hv_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_hv_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_hv_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_hv_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_hv_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_hv_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_hv_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_hv.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_hv_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_hv_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_hv_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_hv_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_id_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_id_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_id_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_id_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_id_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_id_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_id_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_id.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_id_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_id_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_id_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_id_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ii_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ii_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ii_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ii_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ii_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ii_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ii_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ii.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ii_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ii_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ii_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ii_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_io_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_io_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_io_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_io_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_io_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_io_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_io_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_io.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_io_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_io_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_io_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_io_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_lo_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_lo_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_lo_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_lo_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_lo_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_lo_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_lo_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_lo.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_lo_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_lo_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_lo_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_lo_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ma_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ma_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ma_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ma_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ma_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ma_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ma_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ma.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ma_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ma_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ma_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ma_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_mb_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_mb_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_mb_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_mb_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_mb_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_mb_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_mb_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_mb.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_mb_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_mb_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_mb_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_mb_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ms_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ms_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ms_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ms_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ms_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ms_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ms_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ms.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ms_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ms_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ms_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ms_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_or_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_or_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_or_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_or_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_or_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_or_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_or_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_or.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_or_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_or_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_or_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_or_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_pa_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pa_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pa_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pa_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pa_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pa_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pa_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_pa.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pa_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pa_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pa_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pa_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_pd_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pd_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pd_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pd_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pd_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pd_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pd_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_pd.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pd_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pd_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pd_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pd_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_pr_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pr_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pr_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pr_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pr_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pr_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pr_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_pr.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pr_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pr_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pr_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pr_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ps_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ps_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ps_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ps_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ps_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ps_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ps_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_ps.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ps_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ps_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ps_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ps_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_pt_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pt_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pt_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pt_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pt_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pt_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pt_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_pt.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pt_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pt_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pt_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pt_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_rt_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_rt_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_rt_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_rt_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_rt_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_rt_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_rt_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_rt.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_rt_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_rt_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_rt_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_rt_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_se_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_se_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_se_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_se_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_se_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_se_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_se_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_se.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_se_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_se_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_se_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_se_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_up_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_up_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_up_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_up_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_up_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_up_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_up_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_up.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_up_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_up_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_up_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_up_insert

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_us_insert_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_us_insert_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_us_ins.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_us_insert_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_us_insert_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_us_insert_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_us_insert.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_tttl_us.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_us_insert.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_us_insert.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_us_insert...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_us_insert

$dbsqlError
EOF
`;
}

#}#eof of don't run the above code...
#die "I am dying before the update section";
#*************************Initiating update of rows in cpscan tables*************************#


print "***Initiating BCP FROM ASE for driver_stats_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..driver_stats_update_iq_vw out /opt/sybase/bcp_data/cpscan/driver_stats_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From driver_stats_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: driver_stats_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for driver_stats_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_driver_stats_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_driver_stats.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_driver_stats_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_driver_stats_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_driver_stats_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_driver_stats_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for employee_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..employee_update_iq_vw out /opt/sybase/bcp_data/cpscan/employee_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From employee_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: employee_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for employee_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_employee_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_employee.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_employee_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_employee_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_employee_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_employee_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_bi_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_bi_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_bi_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_bi_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_bi_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_bi_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_bi_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_bi.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_bi_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_bi_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_bi_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_bi_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_cp_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_cp_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_cp_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_cp_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_cp_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_cp_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_cp_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_cp.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_cp_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_cp_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_cp_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_cp_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ct_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ct_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ct_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ct_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ct_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ct_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ct_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ct.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ct_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ct_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ct_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ct_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dc_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dc_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dc_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dc_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dc_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dc_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dc_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_dc.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dc_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dc_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dc_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dc_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dex_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dex_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dex_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dex_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dex_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dex_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dex_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_dex.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dex_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dex_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dex_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dex_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dp_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dp_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dp_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dp_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dp_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dp_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dp_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_dp.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dp_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dp_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dp_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dp_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_dr_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_dr_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_dr_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_dr_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_dr_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_dr_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_dr_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_dr.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_dr_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_dr_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_dr_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_dr_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ev_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ev_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ev_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ev_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ev_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ev_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ev_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ev.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ev_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ev_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ev_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ev_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ex_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ex_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ex_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ex_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ex_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ex_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ex_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ex.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ex_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ex_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ex_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ex_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_fl_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_fl_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_fl_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_fl_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_fl_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_fl_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_fl_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_fl.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_fl_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_fl_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_fl_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_fl_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_hc_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_hc_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_hc_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_hc_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_hc_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_hc_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_hc_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_hc.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_hc_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_hc_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_hc_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_hc_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_hv_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_hv_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_hv_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_hv_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_hv_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_hv_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_hv_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_hv.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_hv_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_hv_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_hv_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_hv_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_id_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_id_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_id_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_id_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_id_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_id_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_id_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_id.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_id_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_id_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_id_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_id_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ii_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ii_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ii_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ii_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ii_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ii_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ii_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ii.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ii_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ii_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ii_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ii_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_io_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_io_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_io_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_io_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_io_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_io_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_io_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_io.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_io_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_io_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_io_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_io_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_lo_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_lo_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_lo_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_lo_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_lo_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_lo_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_lo_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_lo.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_lo_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_lo_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_lo_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_lo_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ma_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ma_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ma_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ma_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ma_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ma_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ma_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ma.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ma_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ma_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ma_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ma_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_mb_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_mb_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_mb_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_mb_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_mb_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_mb_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_mb_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_mb.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_mb_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_mb_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_mb_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_mb_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ms_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ms_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ms_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ms_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ms_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ms_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ms_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ms.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ms_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ms_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ms_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ms_update

$dbsqlError
EOF
`;
}

#} #eof don't run the above code
print "***Initiating BCP FROM ASE for tttl_pa_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pa_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pa_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pa_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pa_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pa_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pa_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_pa.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pa_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pa_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pa_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pa_update

$dbsqlError
EOF
`;
}
die;
#}#eof of don't run the above code...
#sleep(60);
print "***Initiating BCP FROM ASE for tttl_pr_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pr_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pr_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pr_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pr_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pr_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pr_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_pr.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pr_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pr_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pr_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pr_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_ps_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_ps_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_ps_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_ps_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_ps_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_ps_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_ps_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_ps.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_ps_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_ps_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_ps_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_ps_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_pt_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_pt_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_pt_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_pt_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_pt_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_pt_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_pt_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_pt.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_pt_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_pt_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_pt_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_pt_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_rt_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_rt_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_rt_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_rt_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_rt_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_rt_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_rt_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_rt.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_rt_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_rt_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_rt_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_rt_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_se_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_se_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_se_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_se_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_se_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_se_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_se_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_se.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_se_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_se_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_se_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_se_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_up_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_up_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_up_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_up_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_up_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_up_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_up_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_up.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_up_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_up_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_up_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_up_update

$dbsqlError
EOF
`;
}

#sleep(60);
print "***Initiating BCP FROM ASE for tttl_us_update_iq At:".localtime()."***\n";
$bcpError = `bcp cpscan..tttl_us_update_iq_vw out /opt/sybase/bcp_data/cpscan/tttl_us_upd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n"`;
if (($bcpError =~ /Msg/ || $bcpError =~ /error/i) && $bcpError !~ /WARNING\!/){
      print "BCP Messages From tttl_us_update_iq...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: tttl_us_update_iq

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

print "***Initiating LOAD TO IQ for tttl_us_update_iq At:".localtime()."***\n";
open(STDERR,"> /tmp/iq_tttl_us_update.err") || print "Can't do it\n";
$dbsqlOut = `dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/update_tttl_us.sql`;

close(STDERR);

open(ERRFILE,"< /tmp/iq_tttl_us_update.err");
read(ERRFILE,$dbsqlError,10000,0);
`rm /tmp/iq_tttl_us_update.err`;
print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlOut !~ /affected/){
      print "Messages From iq_tttl_us_update...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: iq_tttl_us_update

$dbsqlError
EOF
`;
}
