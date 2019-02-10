#!/usr/bin/perl -w

###################################################################################
#Script:   This script synchronizes MTL stats tables from Montreal twice a day.   #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Oct 10 2006	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Setting Sybase environment is set properly


#*************************************************************************************
print "***Initiating load_PACKAGES sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_PACKAGE_mtl.sql 2>&1`;

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
delete packages_mtl where Create_Time < dateadd(dd,-60,getdate())
go   
exit   
EOF

bcp mpr_data..packages_mtl in /opt/sybase/bcp_data/mtldb/PACKAGE_MTL.txt -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -c -t"|:|" -r"\n" -b10000

#touch /tmp/hmi_mtl_load_done

#scp -p /tmp/hmi_mtl_load_done sybase\@cpdb1:/tmp/
`;

print "Messages from mpr_data feed: $sqlError\n";

#*************************************************************************************
print "***Initiating load_attributes sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_attributes_mtl.sql 2>&1`;

print "$dbsqlOut\n";
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

#*************************************************************************************
print "***Initiating load_StatisticClass sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_StatisticClass_mtl.sql 2>&1`;

print "$dbsqlOut\n";
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

#*************************************************************************************
print "***Initiating load_STAT_RATE sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_GRAPH_STATS.sql 2>&1`;

print "$dbsqlOut\n";
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
print "***Initiating load_TimeFragment sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_TimeFragment_mtl.sql 2>&1`;

print "$dbsqlOut\n";
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
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_StatisticsTable_mtl.sql 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_StatisticsTable_mtl

$dbsqlOut
EOF
`;

}

#*************************************************************************************
print "***Initiating load_StatisticsCD sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_StatisticsCD.sql 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: load_StatisticsCD

$dbsqlOut
EOF
`;

}

#*************************************************************************************
print "***Initiating load_TimeInformation sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_TimeInformation_mtl.sql 2>&1`;

print "$dbsqlOut\n";
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

print "***Initiating st_mtl_process sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute st_mtl_process' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: st_mtl_process

$dbsqlOut
EOF
`;

}
