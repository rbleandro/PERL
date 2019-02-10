#!/usr/bin/perl -w

###################################################################################
#Script:   This script synchronizes JCC stats tables from JC center twice a day.  #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#April 13,2005	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################


#*************************************************************************************
print "***Initiating load_PACKAGES sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_PACKAGES.sql 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_PACKAGES

$dbsqlOut
EOF
`;

}

#print "***Initiating packages data feed into mpr_data db At:".localtime()."***\n";
$sqlError= `. /opt/sybase/IQ-15_4/IQ-15_4.sh
/opt/sybase/OCS-15_0/bin/isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -w300 <<EOF 2>&1
use mpr_data
go 
delete packages (index idx2) where Creation_Time < dateadd(dd,-60,getdate())
go 
exit 
EOF

bcp mpr_data..packages in /opt/sybase/bcp_data/ssdb/PACKAGES.txt -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -c -t"|:|" -r"\r\n" -b10000`;

print "Messages from mpr_data feed: $sqlError\n";

#*************************************************************************************
print "***Initiating load_attributes sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_attributes.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_attributes

$dbsqlOut
EOF
`;

}
print "$dbsqlOut\n";

#*************************************************************************************
print "***Initiating load_StatisticClass sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_StatisticClass.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_StatisticClass

$dbsqlOut
EOF
`;

}
print "$dbsqlOut\n";

#*************************************************************************************
print "***Initiating load_STAT_RATE sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_STAT_RATE.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_STAT_RATE

$dbsqlOut
EOF
`;

}

#*************************************************************************************
print "***Initiating load_TimeInformation sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_TimeInformation.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_TimeInformation

$dbsqlOut
EOF
`;

}

#*************************************************************************************
print "***Initiating load_TimeFragment sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_TimeFragment.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_TimeFragment

$dbsqlOut
EOF
`;

}

#*************************************************************************************
print "***Initiating load_StatisticsTable sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_StatisticsTable.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_StatisticsTable

$dbsqlOut
EOF
`;

}

#*************************************************************************************
print "***Initiating load_PACKAGES_HISTORY sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_PACKAGES_HISTORY.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_PACKAGES_HISTORY

$dbsqlOut
EOF
`;

}

print "***Initiating packages_history data feed into mpr_data db At:".localtime()."***\n";
$sqlError= `. /opt/sybase/IQ-15_4/IQ-15_4.sh
/opt/sybase/OCS-15_0/bin/isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -w300 <<EOF 2>&1
use mpr_data
go
delete packages_history where Creation_Time < dateadd(dd,-60,getdate())
go
exit
EOF

bcp mpr_data..packages_history in /opt/sybase/bcp_data/ssdb/PACKAGES_HISTORY.txt -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -c -t"|:|" -r"\r\n" -b10000
`;

print "Messages from mpr_data feed: $sqlError\n";

#*************************************************************************************
print "***Initiating load_PACKAGE_TRANSACTIONS_HISTORY sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_PACKAGE_TRANSACTIONS_HISTORY.sql 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_PACKAGE_TRANSACTIONS_HISTORY

$dbsqlOut
EOF
`;

}

print "***Initiating st_jcc_process sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute st_jcc_process' 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: st_jcc_process

$dbsqlOut
EOF
`;

}

