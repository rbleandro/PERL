#!/usr/bin/perl -w

###################################################################################
#Script:   This script load OBM reports to IQ                                     #
#Author:    Ahsan Ahmed                                                           #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#01/07/04       Ahsan Ahmed     Originally created                                #
#                                                                                 #
#02/23/06      Ahsan Ahmed      Modified for email to DBA's and documentation     #
###################################################################################


#Unzip and Rename these 5 files here follows:

print "\n**********Starting OBM load now...".localtime()."*************\n\n";
#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";
#Removing old csv files to ensure that we have the latest csv files.

$rmDone = `rm /opt/sybase/tmp/*.csv`;
print "Any messages when deleting csv files...$rmDone \n";

$unzipError = `unzip -o /opt/sybase/tmp/Account_Summary_Details.CSV.zip -d /opt/sybase/tmp/ 2>&1`;
print "Unzip Errors: $unzipError \n";

if($unzipError =~ /cannot/){
      print "Errors may have occurred during unzip Account Summary Detail...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com

Subject: ERROR - Unzip OBM files

Following status was received after unzipping on $currTime
$unzipError
EOF
`;

die "\n********Can't proceed further with problems above...\n\n";
   }

$cpError = `cp /opt/sybase/tmp/\'Account_Summary_Details.csv\' /opt/sybase/tmp/acct_sum_det.csv`;

print "cpEroor: $cpError \n";
#die "cannot copy Account Summary Details.csv \n";

$unzipError = `unzip -o /opt/sybase/tmp/EA_Call_Usage.CSV.zip -d /opt/sybase/tmp/`;
print "Unzip Errors: $unzipError \n";

if($unzipError =~ /cannot/){
      print "Errors may have occurred during unzip EA_Call_Usage...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com

Subject: ERROR - Unzip OBM files

Following status was received after unzipping on $currTime
$unzipError
EOF
`;

die "\n********Can't proceed further with problems above...\n\n";
   }

$cpError = `cp /opt/sybase/tmp/\'EA_Call_Usage.csv\' /opt/sybase/tmp/EA_Call.csv`;
print "cpEroor: $cpError \n";
#die "cannot copy EA_Call Usage.csv \n";

$unzipError = `unzip -o /opt/sybase/tmp/EquipmentRecurring_Charges_Details_-_NSB.CSV.zip -d /opt/sybase/tmp/`;
print "Unzip Errors: $unzipError \n";

if($unzipError =~ /cannot/){
      print "Errors may have occurred during unzip EquipmentRecurring_Charges_Details_-_NSB...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com 

Subject: ERROR - Unzip OBM files

Following status was received after unzipping on $currTime
$unzipError
EOF
`;

die "\n********Can't proceed further with problems above...\n\n";
   }

$cpError = `cp /opt/sybase/tmp/\'EquipmentRecurring_Charges_Details_-_NSB.csv\' /opt/sybase/tmp/equip_rec.csv`;

print "cpEroor: $cpError \n";
#die "cannot copy EquipmentRecurring Charges Details - NSB.csv \n";

$unzipError = `unzip -o /opt/sybase/tmp/NSB_Toll_Free_Details.CSV.zip -d /opt/sybase/tmp/`;
print "Unzip Errors: $unzipError \n";

if($unzipError =~ /cannot/){
      print "Errors may have occurred during unzip NSB_Toll_Free_Details.CSV....\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com

Subject: ERROR - Unzip OBM files 

Following status was received after unzipping on $currTime
$unzipError 
EOF
`;

die "\n********Can't proceed further with problems above...\n\n";
   }
$cpError = `cp /opt/sybase/tmp/\'NSB_Toll_Free_Details.csv\' /opt/sybase/tmp/nsb_detail.csv`;

print "cpEroor: $cpError \n";
#die "cannot copy NSB Toll Free Details.csv \n";

$unzipError = `unzip -o /opt/sybase/tmp/\'OCC_&_OTC_Details_-_NSB.CSV.zip\' -d /opt/sybase/tmp/`;
print "Unzip Errors: $unzipError \n";
if($unzipError =~ /cannot/){
      print "Errors may have occurred during unzip OCC_&_OTC_Details_-_NSB.CSV.zip....\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com

Subject: ERROR - Unzip OBM files 

Following status was received after unzipping on $currTime
$unzipError
EOF
`;

die "\n********Can't proceed further with problems above...\n\n";
   }

$cpError = `cp /opt/sybase/tmp/\'OCC_&_OTC_Details_-_NSB.csv\' /opt/sybase/tmp/occ_otc.csv`;

print "cpError: $cpError\n";

#Removing done.done file to ensure that we have the latest ftp next time around.
$rmDone = `rm /opt/sybase/tmp/done.done`;
print "Any messages when deleting done.done...$rmDone \n";

$cpError  = `./remove_header.pl /opt/sybase/tmp/acct_sum_det.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/EA_Call.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/equip_rec.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/nsb_detail.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/occ_otc.csv`;
print "cpError: $cpError\n";

$rmDone = `rm /opt/sybase/tmp/*.bak`;
$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_account_summary_detail.sql 2>&1`;

#die "Unziped, copy, removed header and imported data to IQ\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_equipment_rec_nsb.sql 2>&1`;

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_nsb_toll_free_detail.sql 2>&1`;

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_occ_otc_detail.sql 2>&1`;

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_EA_Call.sql 2>&1`;

#Removing zip files after the process is completed.
#$rmDone = `rm /opt/sybase/tmp/*.zip`;
print "Any messages when deleting zip files...$rmDone \n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com

Subject:  -  OBM files have been imported to IQ. Please check.

Following status was received after unzipping on $currTime
EOF
`;

