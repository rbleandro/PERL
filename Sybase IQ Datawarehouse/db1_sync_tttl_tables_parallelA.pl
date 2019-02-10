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


#*************************Initiating suspension of Replication connection to CPDB1.iq_stage*************************#

$sqlError = `ssh cpdb1.canpar.com '/opt/sybase/cron_scripts/iq_set_prod_connection.pl suspend'`;

if ($sqlError =~ /Msg/ || $sqlError =~ /error/i || $sqlError =~ /Permission denied/i){
      print "Messages From suspend replication...\n";
      print "$sqlError\n";

$isProcessRunning =`ps -ef|grep sybase|grep db1_sync_tttl_tables|grep parallelB|grep -v sh`;
if($isProcessRunning){
   #Do nothing, the other process has suspended the connection already, so just move on...Amer
   print "Will wait for parallelB to finish...\n";
   die;
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

$currHour= sprintf('%02d',((localtime())[2]));

#####################
# Wait for B process
# to start
#####################

print "Waiting for 5 sec for B process to start...".localtime()."\n";
sleep 5;
print "Continuing ...".localtime()."\n";

if ($currHour eq '05'){
print "***Initiating tttl_ev nightly RELOAD At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "insert into tttl_ev_event_2011 IGNORE CONSTRAINT UNIQUE 0 location 'CPDB1.cpscan' packetsize 1024{ select * from tttl_ev_nightly_reload }" 2>&1`;

print "$dbsqlOut\n";

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: tttl_ev_event RELOAD had problems!!

$dbsqlOut
EOF
`;

}
} #eof event reload

print "***Initiating tttl_ev sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "insert into tttl_ev_event_2011 IGNORE CONSTRAINT UNIQUE 0 location 'CPDB1.cpscan' packetsize 1024{ select * from tttl_ev_event_inserts }" 2>&1`;

print "$dbsqlOut\n";

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: tttl_ev_event

$dbsqlOut
EOF
`;

# Then don't run the following
print "Not running truncate tttl_ev_event_inserts\n";
}else{
$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'truncate table db1_tttl_ev_event_inserts' 2>&1`;

print "Truncating event inserts table: $dbsqlOut\n";

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: tttl_ev_event

$dbsqlOut
EOF
`;
}
}

#*******************************************************************************

print "***Initiating svp_parcel LOAD At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_svp_parcel' 2>&1`;

print "$dbsqlOut\n";

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: svp_parcel LOAD had problems!!

$dbsqlOut
EOF
`;

}




print "***Initiating manifest_header sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_manifest_header.sql 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: manifest_header

$dbsqlOut
EOF
`;

}
#*************************************************************************************

print "***Initiating cwparcel sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cwparcel' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cwparcel"){
   $count=`cat /tmp/db1_load_cwparcel`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cwparcel`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cwparcel`;
   $insert_cnt = `echo $count > /tmp/db1_load_cwparcel`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cwparcel

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cwparcel"){
$rm_count=`rm /tmp/db1_load_cwparcel`;
}
}

#**************************************************************************************
print "***Initiating revhsth sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhsth' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhsth"){
   $count=`cat /tmp/db1_load_revhsth`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhsth`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhsth`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhsth`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhsth

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhsth"){
$rm_count=`rm /tmp/db1_load_revhsth`;
}
}

#***************************************************************************************
print "***Initiating revhstf1 sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstf1' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstf1"){
   $count=`cat /tmp/db1_load_revhstf1`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstf1`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstf1`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstf1`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstf1

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstf1"){
$rm_count=`rm /tmp/db1_load_revhstf1`;
}
}

#***************************************************************************************
print "***Initiating bcxref sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_bcxref' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_bcxref"){
   $count=`cat /tmp/db1_load_bcxref`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_bcxref`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_bcxref`;
   $insert_cnt = `echo $count > /tmp/db1_load_bcxref`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_bcxref

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_bcxref"){
$rm_count=`rm /tmp/db1_load_bcxref`;
}
}

#***************************************************************************************
print "***Initiating cwshipment sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_cwshipment' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_cwshipment"){
   $count=`cat /tmp/db1_load_cwshipment`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_cwshipment`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_cwshipment`;
   $insert_cnt = `echo $count > /tmp/db1_load_cwshipment`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_cwshipment

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_cwshipment"){
$rm_count=`rm /tmp/db1_load_cwshipment`;
}
}

#**************************************************************************************
print "***Initiating revhstz sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstz' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstz"){
   $count=`cat /tmp/db1_load_revhstz`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstz`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstz`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstz`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstz

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstz"){
$rm_count=`rm /tmp/db1_load_revhstz`;
}
}

#**************************************************************************************
print "***Initiating revhstr sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstr' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstr"){
   $count=`cat /tmp/db1_load_revhstr`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstr`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstr`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstr`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstr

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstr"){
$rm_count=`rm /tmp/db1_load_revhstr`;
}
}

#**************************************************************************************
print "***Initiating revhstrs sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_revhstrs' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_revhstrs"){
   $count=`cat /tmp/db1_load_revhstrs`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstrs`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_revhstrs`;
   $insert_cnt = `echo $count > /tmp/db1_load_revhstrs`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_revhstrs

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_revhstrs"){
$rm_count=`rm /tmp/db1_load_revhstrs`;
}
}



#**************************************************************************************
print "***Initiating tttl_ma_manifest sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_ma_manifest' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_ma_manifest"){
   $count=`cat /tmp/db1_load_tttl_ma_manifest`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_manifest`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_ma_manifest`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_ma_manifest`;
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_ma_manifest

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_ma_manifest"){
$rm_count=`rm /tmp/db1_load_tttl_ma_manifest`;
}
}

#***************************************************************************************
print "***Initiating tttl_batchdown sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_batchdown' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_batchdown"){
   $count=`cat /tmp/db1_load_tttl_batchdown`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_batchdown`;
   print "Conflict Count: $insert_cnt\n";
}else{
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_batchdown`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_batchdown`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_batchdown

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_batchdown"){
$rm_count=`rm /tmp/db1_load_tttl_batchdown`;
}
}

#*************************************************************************************
print "***Initiating tttl_sortation sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_tttl_sortation' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_tttl_sortation"){
   $count=`cat /tmp/db1_load_tttl_sortation`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_sortation`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_tttl_sortation`;
   $insert_cnt = `echo $count > /tmp/db1_load_tttl_sortation`;
   print "Conflict Count: $insert_cnt\n";
}

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_tttl_sortation

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_tttl_sortation"){
$rm_count=`rm /tmp/db1_load_tttl_sortation`;
}
}

#**********************************************************************************
print "***Initiating phone_statistics sync At:".localtime()."***\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute db1_load_phone_statistics' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /match/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

if (-e "/tmp/db1_load_phone_statistics"){
   $count=`cat /tmp/db1_load_phone_statistics`;
   $count += 1;
   $insert_cnt = `echo $count > /tmp/db1_load_phone_statistics`;
   print "Conflict Count: $insert_cnt\n";
}else{ 
   $count="1";
   $touch_msg = `touch /tmp/db1_load_phone_statistics`;
   $insert_cnt = `echo $count > /tmp/db1_load_phone_statistics`; 
   print "Conflict Count: $insert_cnt\n";
}     

if ($count > "5"){
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: IQ SYNC ERROR: db1_load_phone_statistics

$dbsqlOut
EOF
`;

}

}else{
if (-e "/tmp/db1_load_phone_statistics"){
$rm_count=`rm /tmp/db1_load_phone_statistics`;
}
}

#********************************
# Restarting replication Now
#********************************
$isProcessRunning =`ps -ef|grep sybase|grep db1_sync_tttl_tables|grep parallelB|grep -v sh`;
if($isProcessRunning){
   #Do nothing, the other process will resume the connection
   die "Finishing without resuming the connection, since the parallelB process is still running...\n";
}else{

$sqlError = `ssh cpdb1.canpar.com '/opt/sybase/cron_scripts/iq_set_prod_connection.pl resume'`;

if ($sqlError =~ /Msg/ || $sqlError =~ /error/i || $sqlError =~ /Permission denied/i){
      print "Messages From resume replication...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Replication Connection Resume Error

$sqlError
EOF
`;
}else{ print "Resume Replication Completed With: $sqlError\n"; }
}
