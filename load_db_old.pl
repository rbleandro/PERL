#!/usr/bin/perl

###################################################################################
#Script:   This script loads different databases. All the sql and logic is        #
#          included in this script. Script is supposed to work with all databases.#
#Author:   Amer Khan                                                              #
#Revision:        Ahsan Ahmed                                                                #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/23/03	Amer Khan	Originally created                                #
#                                                                                 #
#07/08/04	Amer Khan	Added code to give complete process time for a    #
#				full dump and load correctly                      #
###################################################################################

#Usage Restrictions
if ($#ARGV < 1){
   print "Usage: load_db.pl CPDB1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
use Sys::Hostname;
$standbyserver = hostname();
}

#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];
$startDay = $ARGV[2];
$startHour = $ARGV[3];
$startMin = $ARGV[4];

$currTime = localtime();

if ($database eq "cpscan"){

print "\n###Killing any users still logged into cpscan###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server cpscan`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database cpscan from 
"/opt/sybase/remote_db_backups/stripe11/cpscan.dmp1"
stripe on "/opt/sybase/remote_db_backups/stripe15/cpscan.dmp1a"
stripe on "/opt/sybase/remote_db_backups/stripe15/cpscan.dmp1b"
stripe on "/opt/sybase/remote_db_backups/stripe12/cpscan.dmp2"
stripe on "/opt/sybase/remote_db_backups/stripe16/cpscan.dmp2a"
stripe on "/opt/sybase/remote_db_backups/stripe16/cpscan.dmp2b"
stripe on "/opt/sybase/remote_db_backups/stripe13/cpscan.dmp3"
stripe on "/opt/sybase/remote_db_backups/stripe17/cpscan.dmp3a"
stripe on "/opt/sybase/remote_db_backups/stripe17/cpscan.dmp3b"
stripe on "/opt/sybase/remote_db_backups/stripe14/cpscan.dmp4"
stripe on "/opt/sybase/remote_db_backups/stripe18/cpscan.dmp4a"
stripe on "/opt/sybase/remote_db_backups/stripe18/cpscan.dmp4b"
go
select "Load of cpscan finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
--dbcc dbrepair(cpscan,ltmignore)
go
online database cpscan --for standby_access
go
use cpscan
go
ALTER TABLE dbo.sales_lead DISABLE TRIGGER dbo.sales_lead_ins
go
exit
EOF
`;
print $onlineError." at ".localtime()."\n\n";
die;

   $resumeError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SSYBREP1 <<EOF 2>&1
resume connection to $standbyserver.cpscan
go
exit
EOF
`;

print "***********Replication Messages***********\n\n$resumeError\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}


`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: DATABASE LOAD: $database

cpscan load completed in $totalHours Hours and $totalMins Minutes
Replicate: $resumeError
EOF
`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
}#eof of failure
}#end of if db = cpscan

if ($database eq "rev_hist"){

print "\n###Killing any users still logged into rev_hist###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server rev_hist`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database rev_hist from "/opt/sybase/remote_db_backups/stripe11/rev_hist.dmp1"
stripe on "/opt/sybase/remote_db_backups/stripe12/rev_hist.dmp2"
stripe on "/opt/sybase/remote_db_backups/stripe13/rev_hist.dmp3"
go
select "Load of rev_hist finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $online/Error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
--dbcc dbrepair(rev_hist,ltmignore)
go
online database rev_hist
go
exit
EOF
`;
print $onlineError."\n";
die;
   $resumeError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SSYBREP1 <<EOF 2>&1
resume connection to $standbyserver.rev_hist
go
exit
EOF
`;

print "***********Replication Messages***********\n\n$resumeError\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: DATBASE LOAD: $database

rev_hist load completed in $totalHours Hours and $totalMins Minutes
EOF
`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = rev_hist


if ($database eq "arch_db"){

print "\n###Killing any users still logged into arch_db###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server arch_db`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
load database arch_db from "/opt/sybase/remote_db_backups/stripe11/arch_db.dmp1"
stripe on "/opt/sybase/remote_db_backups/stripe12/arch_db.dmp2"
stripe on "/opt/sybase/remote_db_backups/stripe13/arch_db.dmp3"
go
select "Load of arch_db finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
--dbcc dbrepair(rev_hist,ltmignore)
go
online database arch_db
go
exit
EOF
`;
print $onlineError."\n";

   $resumeError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SSYBREP1 <<EOF 2>&1
#resume connection to $standbyserver.rev_hist
#go
#exit
EOF
`;

#print "***********Replication Messages***********\n\n$resumeError\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: DATBASE LOAD: $database

arch_db load completed in $totalHours Hours and $totalMins Minutes
EOF
`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = arch_db



if ($database eq "mpr_data"){

print "\n###Killing any users still logged into arch_db###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server mpr_data`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
load database mpr_data from "/opt/sybase/remote_db_backups/stripe11/mpr_data.dmp1"
stripe on "/opt/sybase/remote_db_backups/stripe12/mpr_data.dmp2"
stripe on "/opt/sybase/remote_db_backups/stripe13/mpr_data.dmp3"
go
select "Load of mpr_data finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
--dbcc dbrepair(rev_hist,ltmignore)
go
online database mpr_data
go
exit
EOF
`;
print $onlineError."\n";

   $resumeError = `. /opt/sybase/SYBASE.sh
#isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SSYBREP1 <<EOF 2>&1
#resume connection to $standbyserver.rev_hist
#go
#exit
EOF
`;

#print "***********Replication Messages***********\n\n$resumeError\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: DATBASE LOAD: $database

mpr_data load completed in $totalHours Hours and $totalMins Minutes
EOF
`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = mpr_data

if ($database eq "cmf_data"){

print "\n###Killing any users still logged into cmf_data###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server cmf_data`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database cmf_data from 
	  "/opt/sybase/remote_db_backups/stripe11/cmf_data.dmp1"
stripe on "/opt/sybase/remote_db_backups/stripe12/cmf_data.dmp2"
stripe on "/opt/sybase/remote_db_backups/stripe13/cmf_data.dmp3"
stripe on "/opt/sybase/remote_db_backups/stripe14/cmf_data.dmp4"
go
select "Load of cmf_data finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
online database cmf_data
go
use cmf_data
go
ALTER TABLE dbo.cmfrates DISABLE TRIGGER dbo.perv_del_cmfrates_trg
go
ALTER TABLE dbo.cmfrates DISABLE TRIGGER dbo.perv_ins_cmfrates_trg
go
ALTER TABLE dbo.cmfrates DISABLE TRIGGER dbo.perv_upd_cmfrates_trg
go
ALTER TABLE dbo.cmfshipr DISABLE TRIGGER dbo.perv_del_cmfshipr_trg
go
ALTER TABLE dbo.cmfshipr DISABLE TRIGGER dbo.perv_ins_cmfshipr_trg
go
ALTER TABLE dbo.cmfshipr DISABLE TRIGGER dbo.perv_upd_cmfshipr_trg
go
ALTER TABLE dbo.cparf06i DISABLE TRIGGER dbo.perv_del_cparf06i_trg
go
ALTER TABLE dbo.cparf06i DISABLE TRIGGER dbo.perv_ins_cparf06i_trg
go
ALTER TABLE dbo.cparf06i DISABLE TRIGGER dbo.perv_upd_cparf06i_trg
go
ALTER TABLE dbo.cmfprice DISABLE TRIGGER dbo.perv_del_cmfprice_trg
go
ALTER TABLE dbo.cmfprice DISABLE TRIGGER dbo.perv_ins_cmfprice_trg
go
ALTER TABLE dbo.cmfprice DISABLE TRIGGER dbo.perv_upd_cmfprice_trg
go
ALTER TABLE dbo.cmfextra DISABLE TRIGGER dbo.perv_del_cmfextra_trg
go
ALTER TABLE dbo.cmfextra DISABLE TRIGGER dbo.perv_ins_cmfextra_trg
go
ALTER TABLE dbo.cmfextra DISABLE TRIGGER dbo.perv_upd_cmfextra_trg
go

exit
EOF
`;
print $onlineError."\n";
die;

   $resumeError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SSYBREP1 <<EOF 2>&1
resume connection to $standbyserver.cmf_data
go
exit
EOF
`;

print "***********Replication Messages***********\n\n$resumeError\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: amer_khan\@canpar.com
#Subject: DATABASE LOAD: $database
#
#cmf_data load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = cmf_data

if ($database eq "canship_webdb"){

print "\n###Killing any users still logged into canship_webdb###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server canship_webdb`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database canship_webdb from "/opt/sybase/remote_db_backups/stripe14/canship_webdb.dmp1"
go
select "Load of canship_webdb finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
dbcc dbrepair(canship_webdb,ltmignore)
go
online database canship_webdb
go
exit
EOF
`;
print $onlineError."\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: amer_khan\@canpar.com
#Subject: DATABASE LOAD: $database

#canship_webdb load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = canship_webdb


if ($database eq "canada_post"){

print "\n###Killing any users still logged into canada_post###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server canada_post`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database canada_post from "/opt/sybase/remote_db_backups/stripe14/canada_post.dmp1"
go
select "Load of canada_post finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
dbcc dbrepair(canada_post,ltmignore)
go
online database canada_post
go
exit
EOF
`;
print $onlineError."\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: amer_khan\@canpar.com
#Subject: DATABASE LOAD: $database

#canada_post load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = canada_post

if ($database eq "eput"){

print "\n###Killing any users still logged into eput###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server eput`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database eput from "/opt/sybase/remote_db_backups/stripe14/eput.dmp1"
go
select "Load of eput finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
dbcc dbrepair(eput,ltmignore)
go
online database eput
go
exit
EOF
`;
print $onlineError."\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: amer_khan\@canpar.com
#Subject: DATABASE LOAD: $database

#eput load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = eput

if ($database eq "liberty_db"){

print "\n###Killing any users still logged into liberty_db###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server liberty_db`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database liberty_db from "/opt/sybase/remote_db_backups/stripe14/liberty_db.dmp1"
go
select "Load of liberty_db finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
--dbcc dbrepair(liberty_db,ltmignore)
--go
online database liberty_db
go
exit
EOF
`;
print $onlineError."\n";

   $resumeError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SSYBREP1 <<EOF 2>&1
resume connection to $standbyserver.liberty_db
go
exit
EOF
`;

print "***********Replication Messages***********\n\n$resumeError\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: amer_khan\@canpar.com
#Subject: DATABASE LOAD: $database

#liberty_db load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = liberty_db

####################### Script for cp_timesheet

if ($database eq "cp_timesheet"){

print "\n###Killing any users still logged into cp_timesheet###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server cp_timesheet`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database cp_timesheet from "/opt/sybase/remote_db_backups/stripe19/cp_timesheet.dmp1"
go
select "Load of cp_timesheet finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
online database cp_timesheet
go
exit
EOF
`;
print $onlineError."\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: DATABASE LOAD: $database

#cp_timesheet load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = cp_timesheet

####################### Script for us_ship

if ($database eq "us_ship"){

print "\n###Killing any users still logged into us_ship###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server us_ship`;

print "\n###Loading Database:$database from Server:$server on Host:".`hostname`."###\n";

print "***Initiating Load At:".localtime()."***\n";
$loadError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
load database us_ship from "/opt/sybase/remote_db_backups/stripe19/us_ship.dmp1"
go
select "Load of us_ship finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start ftp...
if($loadError =~ /complete/){
   print "Load was successful at ".localtime()."\n\n";
   $onlineError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
dbcc dbrepair(us_ship,ltmignore)
go
online database us_ship
go
exit
EOF
`;
print $onlineError."\n";

$currDay = sprintf('%02d',((localtime())[6]));
$currHour= sprintf('%02d',((localtime())[2]));
$currHour= sprintf('%02d',((localtime())[2]));
$currMins= sprintf('%02d',((localtime())[1]));

if ($currDay ne $startDay){
   #print "Days are not same...\n";
   $totalHours = (24 - $startHour) + $currHour;
   if ($currMins lt $startMins){
      #print "currMins are lt startMins\n\n";
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      #print "currMins is gt startMins\n\n";
      $totalMins = $currMins - $startMins;
   }
}else{
   $totalHours = $currHour - $startHour;
   if ($currMins lt $startMins){
      $totalHours = $totalHours - 1;
      $totalMins = 60 - ($startMins - $currMins);
   }else{
      $totalMins = $currMins - $startMins;
   }
}

#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: DATABASE LOAD: $database

#us_ship load completed in $totalHours Hours and $totalMins Minutes
#EOF
#`;


print "\n********************\n$error\n*******************\n";
}else{
   print "Load Failed, $loadError\!\n";
   print $loadError."\n";
}#eof of failure
}#end of if db = us_ship
