#!/usr/bin/perl -w

###################################################################################
#Script:   This script synchronizes ASE data to IQ on regular scheduled basis     #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Jan 11 2010	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#####################
# Wait for A process
# to start
#####################

print "Wait for 3 sec to let the A process to start completely...".localtime()."\n";
sleep 5;
print "Continuing ...".localtime()."\n";


#*************************Initiating suspension of Replication connection to CPDB1.iq_stage*************************#

$sqlError = `ssh cpdb1.canpar.com '/opt/sybase/cron_scripts/iq_set_prod_connection.pl suspend'`;

if ($sqlError =~ /Msg/ || $sqlError =~ /error/i || $sqlError =~ /Permission denied/i){
      print "Messages From suspend replication...\n";
      print "$sqlError\n";

$isProcessRunning =`ps -ef|grep sybase|grep db1_sync_tttl_tables|grep parallelA|grep -v sh`;
if($isProcessRunning){
   #Do nothing, the other process has suspended the connection already, so just move on...Amer
   print "Continuing...\n";

}else{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Replication Connection Suspend Error

$sqlError

Dated: \`date\`
EOF
`;

die "Connection Suspension Error...Can't continue...dying!\n\n";
}
}else{ print "$sqlError\n"; }

####################################****************************************###########################################

print "***Initiating tttl_se_search sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_se' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_se"){
   $count=`cat /tmp/db1_load_tttl_se`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_se`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_se`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_se`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_se

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_se"){
$rm_count=`rm /tmp/db1_load_tttl_se`;
}
}

#***********************************************************
print "***Initiating truck_stats sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_truck_stats' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_truck_stats"){
   $count=`cat /tmp/db1_load_truck_stats`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_truck_stats`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_truck_stats`;
   $insert_cnt = `echo $count > /tmp/db1_load_truck_stats`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_truck_stats

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_truck_stats"){
$rm_count=`rm /tmp/db1_load_truck_stats`;
}
}

#*************************************************************
print "***Initiating tttl_pr_pickup_record sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_pr' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_pr"){
   $count=`cat /tmp/db1_load_tttl_pr`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_pr`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_pr`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_pr`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_pr

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_pr"){
$rm_count=`rm /tmp/db1_load_tttl_pr`;
}
}

#***********************************************************
print "***Initiating driver_stats sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_driver_stats' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_driver_stats"){
   $count=`cat /tmp/db1_load_driver_stats`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_driver_stats`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_driver_stats`;
   $insert_cnt = `echo $count > /tmp/db1_load_driver_stats`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_driver_stats

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_driver_stats"){
$rm_count=`rm /tmp/db1_load_driver_stats`;
}
}

#************************************************************
print "***Initiating tttl_ma_barcode sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ma_barcode' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ma_barcode"){
   $count=`cat /tmp/db1_load_tttl_ma_barcode`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_barcode`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ma_barcode`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_barcode`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ma_barcode

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ma_barcode"){
$rm_count=`rm /tmp/db1_load_tttl_ma_barcode`;
}
}

#*************************************************************
print "***Initiating tttl_ma_COD sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ma_COD' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ma_COD"){
   $count=`cat /tmp/db1_load_tttl_ma_COD`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_COD`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ma_COD`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_COD`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ma_COD

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ma_COD"){
$rm_count=`rm /tmp/db1_load_tttl_ma_COD`;
}
}

#************************************************************
print "***Initiating tttl_ma_document sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ma_document' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ma_document"){
   $count=`cat /tmp/db1_load_tttl_ma_document`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_document`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ma_document`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_document`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ma_document

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ma_document"){
$rm_count=`rm /tmp/db1_load_tttl_ma_document`;
}
}

#***********************************************************
print "***Initiating tttl_ma_other sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ma_other' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ma_other"){
   $count=`cat /tmp/db1_load_tttl_ma_other`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_other`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ma_other`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_other`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ma_other

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ma_other"){
$rm_count=`rm /tmp/db1_load_tttl_ma_other`;
}
}

#***********************************************************
print "***Initiating tttl_ma_shipment sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ma_shipment' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ma_shipment"){
   $count=`cat /tmp/db1_load_tttl_ma_shipment`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_shipment`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ma_shipment`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_shipment`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ma_shipment

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ma_shipment"){
$rm_count=`rm /tmp/db1_load_tttl_ma_shipment`;
}
}

#***********************************************************
print "***Initiating cwscans sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cwscans' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cwscans"){
   $count=`cat /tmp/db1_load_cwscans`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cwscans`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cwscans`;
   $insert_cnt = `echo $count > /tmp/db1_load_cwscans`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cwscans

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cwscans"){
$rm_count=`rm /tmp/db1_load_cwscans`;
}
}

#*************************************************************************************
if (1==2){ #####Do not uncomment until fixed!!!!!!!!!!!

print "***Initiating F_PU200412_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200412_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200412_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200501_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200501_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200501_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200502_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200502_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200502_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200503_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200503_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200503_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200504_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200504_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200504_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200505_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200505_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200505_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200506_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200506_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200506_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200507_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200507_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200507_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200508_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200508_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200508_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200509_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200509_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200509_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200510_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200510_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200510_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200511_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200511_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200511_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200512_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200512_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200512_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200601_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200601_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200601_Rec

$dbsqlOut
EOf
`;

}

print "***Initiating F_PU200602_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200602_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200602_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200603_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200603_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200603_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200604_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200604_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200604_Rec

$dbsqlOut
EOF
`;

print "Sync Error...Continuing with tttl_pa_parcel load...!\n\n";
}

print "***Initiating F_PU200605_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200605_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200605_Rec

$dbsqlOut
EOF
`;

print "Sync Error...Continuing with tttl_pa_parcel load...!\n\n";
}

print "***Initiating F_PU200606_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200606_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200606_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200607_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200607_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200607_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200608_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200608_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200608_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200609_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200609_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200609_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200610_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200610_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200610_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200611_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200611_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200611_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200612_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200612_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200612_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200701_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200701_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200701_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200702_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200702_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200702_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200703_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200703_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200703_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200704_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200704_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200704_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200705_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200705_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200705_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200706_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200706_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200706_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200707_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200707_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200707_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200708_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200708_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200708_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200709_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200709_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200709_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200710_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200710_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200710_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200711_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200711_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200711_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200712_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200712_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200712_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200801_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200801_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200801_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200802_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200802_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200802_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200803_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200803_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200803_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200804_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200804_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200804_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200805_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200805_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200805_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200806_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200806_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200806_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200807_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200807_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200807_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200808_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200808_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200808_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200809_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200809_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200809_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200810_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200810_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200810_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200811_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200811_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200811_Rec

$dbsqlOut
EOF
`;

}

print "***Initiating F_PU200812_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PU200812_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PU200812_Rec

$dbsqlOut
EOF
`;

print "Sync Error...Continuing with qmaaudit load...!\n\n";
}

} ##eof 1==2 ##################

#**********************************************************************************************
print "***Initiating qmaaudit sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_qmaaudit' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_qmaaudit"){
   $count=`cat /tmp/db1_load_qmaaudit`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_qmaaudit`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_qmaaudit`;
   $insert_cnt = `echo $count > /tmp/db1_load_qmaaudit`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_qmaaudit

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_qmaaudit"){
$rm_count=`rm /tmp/db1_load_qmaaudit`;
}
}

#***************************************************************************************
print "***Initiating dsshipment sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsshipment' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsshipment"){
   $count=`cat /tmp/db1_load_dsshipment`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsshipment`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsshipment`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsshipment`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsshipment

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsshipment"){
$rm_count=`rm /tmp/db1_load_dsshipment`;
}
}

#***************************************************************************************
if (1==2){
print "***Initiating F_PUProc_Rec sync At:".localtime()."***\n";
open(STDERR,"> /tmp/sync.err") || print "Can't do it\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_F_PUProc_Rec' 2>&1`;

close(STDERR);

open(ERRFILE,"< /tmp/sync.err");
read(ERRFILE,$dbsqlOut,10000,0);
`rm /tmp/sync.err`;
print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: F_PUProc_Rec

$dbsqlOut
EOF
`;

print "Sync Error...Continuing with tttl_ac_address_correction load...!\n\n";
}

} ##eof 1==2 ##############
#***************************************************************************
print "***Initiating tttl_ac_address_correction sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ac_address_correction' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/tttl_address_correction"){ 
   $count=`cat /tmp/tttl_address_correction`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/tttl_address_correction`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/tttl_address_correction`;
   $insert_cnt = `echo $count > /tmp/tttl_address_correction`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5" && $count < "7"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: tttl_address_correction

$dbsqlOut
EOF
`;

} 

}else{
if (-e "/tmp/tttl_address_correction"){
$rm_count=`rm /tmp/tttl_address_correction`;
}
}

#********************************************************************************

print "***Initiating tttl_pa sync At:".localtime()."***\n";
$dbsqlOut="";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_pa' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_pa"){
   $count=`cat /tmp/db1_load_tttl_pa`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_pa`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1"; 
   $touch_msg = `touch /tmp/db1_load_tttl_pa`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_pa`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_pa
      
$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_pa"){
$rm_count=`rm /tmp/db1_load_tttl_pa`;
}
}

#********************************************************************************

print "***Initiating web_putagdetail sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_web_putagdetail' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_web_putagdetail"){
   $count=`cat /tmp/db1_load_web_putagdetail`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_web_putagdetail`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_web_putagdetail`;
   $insert_cnt = `echo $count > /tmp/db1_load_web_putagdetail`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_web_putagdetail

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_web_putagdetail"){
$rm_count=`rm /tmp/db1_load_web_putagdetail`;
}
}


#********************************************************************************

print "***Initiating cmf_baudit_dtls sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cmf_baudit_dtls' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cmf_baudit_dtls"){
   $count=`cat /tmp/db1_load_cmf_baudit_dtls`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cmf_baudit_dtls`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cmf_baudit_dtls`;
   $insert_cnt = `echo $count > /tmp/db1_load_cmf_baudit_dtls`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cmf_baudit_dtls

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cmf_baudit_dtls"){
$rm_count=`rm /tmp/db1_load_cmf_baudit_dtls`;
}
}

#********************************************************************************

print "***Initiating interline_costs sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_interline_costs' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_interline_costs"){
   $count=`cat /tmp/db1_load_interline_costs`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_interline_costs`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_interline_costs`;
   $insert_cnt = `echo $count > /tmp/db1_load_interline_costs`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_interline_costs

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_interline_costs"){
$rm_count=`rm /tmp/db1_load_interline_costs`;
}
}


#********************************************************************************

print "***Initiating linehaul_costs sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_linehaul_costs' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_linehaul_costs"){
   $count=`cat /tmp/db1_load_linehaul_costs`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_linehaul_costs`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_linehaul_costs`;
   $insert_cnt = `echo $count > /tmp/db1_load_linehaul_costs`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_linehaul_costs

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_linehaul_costs"){
$rm_count=`rm /tmp/db1_load_linehaul_costs`;
}
}

#********************************************************************************

print "***Initiating cmfextra2 sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cmfextra2' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cmfextra2"){
   $count=`cat /tmp/db1_load_cmfextra2`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cmfextra2`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cmfextra2`;
   $insert_cnt = `echo $count > /tmp/db1_load_cmfextra2`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cmfextra2

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cmfextra2"){
$rm_count=`rm /tmp/db1_load_cmfextra2`;
}
}

#********************************************************************************

print "***Initiating dsbarcode sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsbarcode' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsbarcode"){
   $count=`cat /tmp/db1_load_dsbarcode`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsbarcode`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsbarcode`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsbarcode`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsbarcode

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsbarcode"){
$rm_count=`rm /tmp/db1_load_dsbarcode`;
}
}

#********************************************************************************

print "***Initiating dsbarcode_orig sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsbarcode_orig' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsbarcode_orig"){
   $count=`cat /tmp/db1_load_dsbarcode_orig`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsbarcode_orig`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsbarcode_orig`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsbarcode_orig`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsbarcode_orig

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsbarcode_orig"){
$rm_count=`rm /tmp/db1_load_dsbarcode_orig`;
}
}

#********************************************************************************

print "***Initiating dsbarcode_trail sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsbarcode_trail' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsbarcode_trail"){
   $count=`cat /tmp/db1_load_dsbarcode_trail`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsbarcode_trail`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsbarcode_trail`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsbarcode_trail`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsbarcode_trail

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsbarcode_trail"){
$rm_count=`rm /tmp/db1_load_dsbarcode_trail`;
}
}

#********************************************************************************

print "***Initiating dsnotes sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsnotes' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsnotes"){
   $count=`cat /tmp/db1_load_dsnotes`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsnotes`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsnotes`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsnotes`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsnotes

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsnotes"){
$rm_count=`rm /tmp/db1_load_dsnotes`;
}
}

#********************************************************************************

print "***Initiating dsshipment_orig sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsshipment_orig' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsshipment_orig"){
   $count=`cat /tmp/db1_load_dsshipment_orig`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsshipment_orig`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsshipment_orig`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsshipment_orig`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsshipment_orig

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsshipment_orig"){
$rm_count=`rm /tmp/db1_load_dsshipment_orig`;
}
}

#********************************************************************************

print "***Initiating dsshipment_trail sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dsshipment_trail' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dsshipment_trail"){
   $count=`cat /tmp/db1_load_dsshipment_trail`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dsshipment_trail`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dsshipment_trail`;
   $insert_cnt = `echo $count > /tmp/db1_load_dsshipment_trail`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dsshipment_trail

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dsshipment_trail"){
$rm_count=`rm /tmp/db1_load_dsshipment_trail`;
}
}

#********************************************************************************

print "***Initiating flash_adjustments sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_flash_adjustments' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_flash_adjustments"){
   $count=`cat /tmp/db1_load_flash_adjustments`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_flash_adjustments`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_flash_adjustments`;
   $insert_cnt = `echo $count > /tmp/db1_load_flash_adjustments`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_flash_adjustments

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_flash_adjustments"){
$rm_count=`rm /tmp/db1_load_flash_adjustments`;
}
}

#********************************************************************************

print "***Initiating points sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_points' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_points"){
   $count=`cat /tmp/db1_load_points`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_points`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_points`;
   $insert_cnt = `echo $count > /tmp/db1_load_points`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_points

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_points"){
$rm_count=`rm /tmp/db1_load_points`;
}
}

#********************************************************************************

print "***Initiating rate_assoc_grouping sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_rate_assoc_grouping' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_rate_assoc_grouping"){
   $count=`cat /tmp/db1_load_rate_assoc_grouping`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_rate_assoc_grouping`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_rate_assoc_grouping`;
   $insert_cnt = `echo $count > /tmp/db1_load_rate_assoc_grouping`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_rate_assoc_grouping

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_rate_assoc_grouping"){
$rm_count=`rm /tmp/db1_load_rate_assoc_grouping`;
}
}

#********************************************************************************

print "***Initiating revhstt sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstt' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstt"){
   $count=`cat /tmp/db1_load_revhstt`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstt`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstt`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstt`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstt

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstt"){
$rm_count=`rm /tmp/db1_load_revhstt`;
}
}


#********************************************************************************
print "***Initiating srvc_times_ground sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_srvc_times_ground' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_srvc_times_ground"){
   $count=`cat /tmp/db1_load_srvc_times_ground`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_srvc_times_ground`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_srvc_times_ground`;
   $insert_cnt = `echo $count > /tmp/db1_load_srvc_times_ground`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_srvc_times_ground

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_srvc_times_ground"){
$rm_count=`rm /tmp/db1_load_srvc_times_ground`;
}
}
#********************************************************************************

print "***Initiating srvc_times_select sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_srvc_times_select' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_srvc_times_select"){
   $count=`cat /tmp/db1_load_srvc_times_select`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_srvc_times_select`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_srvc_times_select`;
   $insert_cnt = `echo $count > /tmp/db1_load_srvc_times_select`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_srvc_times_select

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_srvc_times_select"){
$rm_count=`rm /tmp/db1_load_srvc_times_select`;
}
}

#********************************************************************************

print "***Initiating ba_barcode_audit sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_ba_barcode_audit' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_ba_barcode_audit"){
   $count=`cat /tmp/db1_load_ba_barcode_audit`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_ba_barcode_audit`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_ba_barcode_audit`;
   $insert_cnt = `echo $count > /tmp/db1_load_ba_barcode_audit`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_ba_barcode_audit

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_ba_barcode_audit"){
$rm_count=`rm /tmp/db1_load_ba_barcode_audit`;
}
}


#********************************************************************************

print "***Initiating can_cost sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_can_cost' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_can_cost"){
   $count=`cat /tmp/db1_load_can_cost`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_can_cost`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_can_cost`;
   $insert_cnt = `echo $count > /tmp/db1_load_can_cost`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_can_cost

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_can_cost"){
$rm_count=`rm /tmp/db1_load_can_cost`;
}
}

#********************************************************************************

print "***Initiating cost_master sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cost_master' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cost_master"){
   $count=`cat /tmp/db1_load_cost_master`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cost_master`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cost_master`;
   $insert_cnt = `echo $count > /tmp/db1_load_cost_master`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cost_master

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cost_master"){
$rm_count=`rm /tmp/db1_load_cost_master`;
}
}

#********************************************************************************

print "***Initiating employee sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_employee' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_employee"){
   $count=`cat /tmp/db1_load_employee`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_employee`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_employee`;
   $insert_cnt = `echo $count > /tmp/db1_load_employee`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_employee

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_employee"){
$rm_count=`rm /tmp/db1_load_employee`;
}
}


#********************************************************************************

print "***Initiating manifest_detail sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_manifest_detail' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_manifest_detail"){
   $count=`cat /tmp/db1_load_manifest_detail`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_manifest_detail`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_manifest_detail`;
   $insert_cnt = `echo $count > /tmp/db1_load_manifest_detail`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_manifest_detail

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_manifest_detail"){
$rm_count=`rm /tmp/db1_load_manifest_detail`;
}
}

#********************************************************************************

print "***Initiating cwstudy sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cwstudy' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cwstudy"){
   $count=`cat /tmp/db1_load_cwstudy`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cwstudy`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cwstudy`;
   $insert_cnt = `echo $count > /tmp/db1_load_cwstudy`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cwstudy

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cwstudy"){
$rm_count=`rm /tmp/db1_load_cwstudy`;
}
}

#********************************************************************************

print "***Initiating dimweight sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_dimweight' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_dimweight"){
   $count=`cat /tmp/db1_load_dimweight`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_dimweight`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_dimweight`;
   $insert_cnt = `echo $count > /tmp/db1_load_dimweight`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_dimweight

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_dimweight"){
$rm_count=`rm /tmp/db1_load_dimweight`;
}
}


#********************************************************************************

print "***Initiating revhstd sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstd' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstd"){
   $count=`cat /tmp/db1_load_revhstd`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstd`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstd`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstd`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstd

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstd"){
$rm_count=`rm /tmp/db1_load_revhstd`;
}
}

#********************************************************************************

print "***Initiating revhstm sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstm' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstm"){
   $count=`cat /tmp/db1_load_revhstm`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstm`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstm`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstm`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstm

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstm"){
$rm_count=`rm /tmp/db1_load_revhstm`;
}
}

#********************************************************************************

print "***Initiating revhsts sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhsts' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhsts"){
   $count=`cat /tmp/db1_load_revhsts`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhsts`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhsts`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhsts`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhsts

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhsts"){
$rm_count=`rm /tmp/db1_load_revhsts`;
}
}

#********************************************************************************

print "***Initiating revhstd1 sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstd1' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstd1"){
   $count=`cat /tmp/db1_load_revhstd1`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstd1`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstd1`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstd1`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstd1

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstd1"){
$rm_count=`rm /tmp/db1_load_revhstd1`;
}
}


#********************************************************************************

print "***Initiating rurpers sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_rurpers' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_rurpers"){
   $count=`cat /tmp/db1_load_rurpers`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_rurpers`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_rurpers`;
   $insert_cnt = `echo $count > /tmp/db1_load_rurpers`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_rurpers

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_rurpers"){
$rm_count=`rm /tmp/db1_load_rurpers`;
}
}

#********************************************************************************

print "***Initiating terminal sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_terminal' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_terminal"){
   $count=`cat /tmp/db1_load_terminal`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_terminal`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_terminal`;
   $insert_cnt = `echo $count > /tmp/db1_load_terminal`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_terminal

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_terminal"){
$rm_count=`rm /tmp/db1_load_terminal`;
}
}

#********************************************************************************

print "***Initiating tttl_bi_bulk_inbound sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_bi_bulk_inbound' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_bi_bulk_inbound"){
   $count=`cat /tmp/db1_load_tttl_bi_bulk_inbound`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_bi_bulk_inbound`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_bi_bulk_inbound`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_bi_bulk_inbound`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_bi_bulk_inbound

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_bi_bulk_inbound"){
$rm_count=`rm /tmp/db1_load_tttl_bi_bulk_inbound`;
}
}

#********************************************************************************

print "***Initiating tttl_cp_cod_package sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_cp_cod_package' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_cp_cod_package"){
   $count=`cat /tmp/db1_load_tttl_cp_cod_package`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_cp_cod_package`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_cp_cod_package`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_cp_cod_package`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_cp_cod_package

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_cp_cod_package"){
$rm_count=`rm /tmp/db1_load_tttl_cp_cod_package`;
}
}

#********************************************************************************

print "***Initiating tttl_ct_cod_totals sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ct_cod_totals' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ct_cod_totals"){
   $count=`cat /tmp/db1_load_tttl_ct_cod_totals`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ct_cod_totals`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ct_cod_totals`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ct_cod_totals`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ct_cod_totals

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ct_cod_totals"){
$rm_count=`rm /tmp/db1_load_tttl_ct_cod_totals`;
}
}

#********************************************************************************

print "***Initiating tttl_xc_extra_care sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_xc_extra_care' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_xc_extra_care"){
   $count=`cat /tmp/db1_load_tttl_xc_extra_care`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_xc_extra_care`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_xc_extra_care`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_xc_extra_care`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_xc_extra_care

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_xc_extra_care"){
$rm_count=`rm /tmp/db1_load_tttl_xc_extra_care`;
}
}

#********************************************************************************

print "***Initiating tttl_dc sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_dc' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_dc"){
   $count=`cat /tmp/db1_load_tttl_dc`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_dc`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_dc`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_dc`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_dc

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_dc"){
$rm_count=`rm /tmp/db1_load_tttl_dc`;
}
}

#********************************************************************************

print "***Initiating tttl_dex sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_dex' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_dex"){
   $count=`cat /tmp/db1_load_tttl_dex`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_dex`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_dex`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_dex`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_dex

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_dex"){
$rm_count=`rm /tmp/db1_load_tttl_dex`;
}
}

#********************************************************************************

print "***Initiating tttl_dr sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_dr' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_dr"){
   $count=`cat /tmp/db1_load_tttl_dr`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_dr`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_dr`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_dr`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_dr

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_dr"){
$rm_count=`rm /tmp/db1_load_tttl_dr`;
}
}

#********************************************************************************

print "***Initiating tttl_ps sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ps' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ps"){
   $count=`cat /tmp/db1_load_tttl_ps`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ps`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
  $touch_msg = `touch /tmp/db1_load_tttl_ps`;
 $insert_cnt = `echo $count > /tmp/db1_load_tttl_ps`;
print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ps

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ps"){
$rm_count=`rm /tmp/db1_load_tttl_ps`;
}
}


#********************************************************************************

print "***Initiating tttl_up sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_up' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_up"){
   $count=`cat /tmp/db1_load_tttl_up`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_up`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_up`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_up`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_up

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_up"){
$rm_count=`rm /tmp/db1_load_tttl_up`;
}
}

#********************************************************************************

print "***Initiating tttl_us sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_us' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_us"){
   $count=`cat /tmp/db1_load_tttl_us`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_us`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_us`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_us`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_us

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_us"){
$rm_count=`rm /tmp/db1_load_tttl_us`;
}
}

#********************************************************************************

print "***Initiating tttl_ex sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ex' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ex"){
   $count=`cat /tmp/db1_load_tttl_ex`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ex`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ex`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ex`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ex

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ex"){
$rm_count=`rm /tmp/db1_load_tttl_ex`;
}
}

#********************************************************************************

print "***Initiating tttl_fl sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_fl' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_fl"){
   $count=`cat /tmp/db1_load_tttl_fl`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_fl`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_fl`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_fl`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_fl

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_fl"){
$rm_count=`rm /tmp/db1_load_tttl_fl`;
}
}

#********************************************************************************

print "***Initiating tttl_hc sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_hc' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_hc"){
   $count=`cat /tmp/db1_load_tttl_hc`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_hc`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_hc`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_hc`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_hc

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_hc"){
$rm_count=`rm /tmp/db1_load_tttl_hc`;
}
}

#********************************************************************************

print "***Initiating tttl_hv sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_hv' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_hv"){
   $count=`cat /tmp/db1_load_tttl_hv`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_hv`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_hv`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_hv`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_hv

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_hv"){
$rm_count=`rm /tmp/db1_load_tttl_hv`;
}
}

#********************************************************************************

print "***Initiating tttl_id sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_id' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_id"){
   $count=`cat /tmp/db1_load_tttl_id`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_id`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_id`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_id`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_id

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_id"){
$rm_count=`rm /tmp/db1_load_tttl_id`;
}
}

#********************************************************************************

print "***Initiating tttl_ii sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ii' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ii"){
   $count=`cat /tmp/db1_load_tttl_ii`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ii`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ii`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ii`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ii

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ii"){
$rm_count=`rm /tmp/db1_load_tttl_ii`;
}
}

#********************************************************************************

print "***Initiating tttl_incompat sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_incompat' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_incompat"){
   $count=`cat /tmp/db1_load_tttl_incompat`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_incompat`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_incompat`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_incompat`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_incompat

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_incompat"){
$rm_count=`rm /tmp/db1_load_tttl_incompat`;
}
}

#********************************************************************************

print "***Initiating tttl_io sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_io' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_io"){
   $count=`cat /tmp/db1_load_tttl_io`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_io`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_io`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_io`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_io

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_io"){
$rm_count=`rm /tmp/db1_load_tttl_io`;
}
}

#********************************************************************************

print "***Initiating tttl_lo sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_lo' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_lo"){
   $count=`cat /tmp/db1_load_tttl_lo`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_lo`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_lo`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_lo`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_lo

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_lo"){
$rm_count=`rm /tmp/db1_load_tttl_lo`;
}
}

#********************************************************************************

print "***Initiating tttl_mb sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_mb' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_mb"){
   $count=`cat /tmp/db1_load_tttl_mb`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_mb`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_mb`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_mb`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_mb

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_mb"){
$rm_count=`rm /tmp/db1_load_tttl_mb`;
}
}

#********************************************************************************

print "***Initiating tttl_ms sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ms' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ms"){
   $count=`cat /tmp/db1_load_tttl_ms`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ms`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ms`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ms`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ms

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ms"){
$rm_count=`rm /tmp/db1_load_tttl_ms`;
}
}

#********************************************************************************

print "***Initiating tttl_or sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_or' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_or"){
   $count=`cat /tmp/db1_load_tttl_or`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_or`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_or`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_or`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_or

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_or"){
$rm_count=`rm /tmp/db1_load_tttl_or`;
}
}

#********************************************************************************

print "***Initiating tttl_pt sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_pt' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_pt"){
   $count=`cat /tmp/db1_load_tttl_pt`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_pt`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_pt`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_pt`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_pt

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_pt"){
$rm_count=`rm /tmp/db1_load_tttl_pt`;
}
}

#********************************************************************************

print "***Initiating cmfextra sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cmfextra' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cmfextra"){
   $count=`cat /tmp/db1_load_cmfextra`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cmfextra`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cmfextra`;
   $insert_cnt = `echo $count > /tmp/db1_load_cmfextra`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cmfextra

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cmfextra"){
$rm_count=`rm /tmp/db1_load_cmfextra`;
}
}
 
#********************************************************************************

print "***Initiating XBATCH_DATA sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_XBATCH_DATA' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_XBATCH_DATA"){
   $count=`cat /tmp/db1_load_XBATCH_DATA`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_XBATCH_DATA`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_XBATCH_DATA`;
   $insert_cnt = `echo $count > /tmp/db1_load_XBATCH_DATA`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList1\@canpar.com
Subject: IQ SYNC ERROR: db1_load_XBATCH_DATA

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_XBATCH_DATA"){
$rm_count=`rm /tmp/db1_load_XBATCH_DATA`;
}
}

#********************************************************************************

print "***Initiating XITEMS_DATA sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_XITEMS_DATA' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_XITEMS_DATA"){
   $count=`cat /tmp/db1_load_XITEMS_DATA`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_XITEMS_DATA`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_XITEMS_DATA`;
   $insert_cnt = `echo $count > /tmp/db1_load_XITEMS_DATA`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_XITEMS_DATA

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_XITEMS_DATA"){
$rm_count=`rm /tmp/db1_load_XITEMS_DATA`;
}
}

#********************************************************************************

print "***Initiating XManif_DATA sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_XManif_DATA' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_XManif_DATA"){
   $count=`cat /tmp/db1_load_XManif_DATA`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_XManif_DATA`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_XManif_DATA`;
   $insert_cnt = `echo $count > /tmp/db1_load_XManif_DATA`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_XManif_DATA

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_XManif_DATA"){
$rm_count=`rm /tmp/db1_load_XManif_DATA`;
}
}

#********************************************************************************

print "***Initiating XCUSTLIST_DATA sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_XCUSTLIST_DATA' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_XCUSTLIST_DATA"){
   $count=`cat /tmp/db1_load_XCUSTLIST_DATA`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_XCUSTLIST_DATA`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_XCUSTLIST_DATA`;
   $insert_cnt = `echo $count > /tmp/db1_load_XCUSTLIST_DATA`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_XCUSTLIST_DATA

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_XCUSTLIST_DATA"){
$rm_count=`rm /tmp/db1_load_XCUSTLIST_DATA`;
}
}

#********************************************************************************

print "***Initiating ShipperPref sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_ShipperPref' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_ShipperPref"){
   $count=`cat /tmp/db1_load_ShipperPref`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_ShipperPref`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_ShipperPref`;
   $insert_cnt = `echo $count > /tmp/db1_load_ShipperPref`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_ShipperPref

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_ShipperPref"){
$rm_count=`rm /tmp/db1_load_ShipperPref`;
}
}

#********************************************************************************

print "***Initiating XDEFINED_GOODS sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_XDEFINED_GOODS' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_XDEFINED_GOODS"){
   $count=`cat /tmp/db1_load_XDEFINED_GOODS`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_XDEFINED_GOODS`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_XDEFINED_GOODS`;
   $insert_cnt = `echo $count > /tmp/db1_load_XDEFINED_GOODS`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "0"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_XDEFINED_GOODS

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_XDEFINED_GOODS"){
$rm_count=`rm /tmp/db1_load_XDEFINED_GOODS`;
}
}

#******************************************************************************
#####################
# Wait for one minute
# to give some distance between the two processes
#####################

print "Wait for 1 minute...".localtime()."\n";
sleep 55;
print "Continuing With Resume Replication...".localtime()."\n";

################################################################################

$isProcessRunning =`ps -ef|grep sybase|grep db1_sync_tttl_tables|grep parallelA|grep -v sh`;
if($isProcessRunning){
   #Do nothing, the other process will resume the connection
   die "Finishing without resuming the connection, since the parallelA process is still running...\n";
}else{

$sqlError = `ssh cpdb1.canpar.com '/opt/sybase/cron_scripts/iq_set_prod_connection.pl resume'`;

if ($sqlError =~ /Msg/ || $sqlError =~ /error/i || $sqlError =~ /Permission denied/i){
      print "Messages From resume replication...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: cpiq1 resume error

$sqlError
EOF
`;
}else{ print "Resume Replication Completed With: $sqlError\n"; }
}
