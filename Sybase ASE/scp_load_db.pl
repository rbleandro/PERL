#!/usr/bin/perl -w

###################################################################################
#Script:   This script dumps different databases. All the sql and logic is        #
#          included in this script. Script is supposed to work with all databases.#
#          This script also secure copy the dump to CPDATA1 and then call the     #
#          Load_DB script to load the dump to CPDATA1 including email and page    #
#          DBA's if fail or successful.                                           #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/19/03	Amer Khan	Originally created                                #
#01/12/04	Amer Khan	Modified to reflect time in email correctly       #
#05/07/04	Amer Khan	Move dump/tran files to weekly/daily folder for   #
#                               tape backup through veritas                       #
#07/05/04	Amer Khan	Added IQ load commands here so that they may run  #
#				only when the load finishes                       #
#                                                                                 #
#07/08/04	Amer Khan	Added one param for startDay to fix the time      #
#                               reported to complete a full dump and load process #
#02/21/06	Ahsan Ahmed	Added script for cp_timesheet & us_sship database #
#                               Also, added email to DBA's.                       #
#                                                                                 #
#12/22/06      Ahsan Ahmed      Modified                                          #
#09/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "9" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}
else
{
   $standbyserver = "CPDB2";
}
if ($#ARGV eq "0"){
    $database = $ARGV[0];
    $dumptype = "dumpload";
}
if ($#ARGV eq "1"){
    $database = $ARGV[0];
    $dumptype = $ARGV[1];
}

$testserver = "cpsybtest";
$ipaddress = "10.3.1.159";
#Usage Restrictions
if ($#ARGV > 1){
   print "Usage: dumpdb.pl cpscan optional (dumponly) \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

if ($dumptype eq "dumponly"){
	}else{
 	if ($dumptype eq "dumpload"){
		}else{
			die "Please enter the proper Argument (dumponly)\n";
	}
}


print "\n***********************************\ndatabase: $database dumptype: $dumptype standbyserver: $standbyserver prod: $prodserver \n***********************\n";


#Store inputs
$database = $ARGV[0];

#Set starting variables
$currTime = localtime();
$startDay=sprintf('%02d',((localtime())[6]));
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

use POSIX qw(strftime);
$currDay = lc(strftime "%A", localtime);

#Weekly maintenance, move full db dumps to the weekly folder, before the next dump...
if ($currDay eq "saturday" && $database eq "cmf_data"){

#   `scp -r /opt/sybase/cron_scripts/\* sybase\@cpdb2:/opt/sybase/db_backups/weekly/CPDB1/ASE_cron/`;
#   `scp -r /opt/sybase/SYBSsa9/cron_scripts/\* sybase\@cpdb2:/opt/sybase/db_backups/weekly/CPDB1/ASA_cron/`;
#   `ssh cpdb2.canpar.com 'cp /opt/sybase/cron_scripts/\* /opt/sybase/db_backups/weekly/CPDB2/ASE_cron/'`;
#   `ssh cpdb2.canpar.com 'cp /opt/sybase/SYBSsa9/cron_scripts/\* /opt/sybase/db_backups/weekly/CPDB2/ASA_cron/'`;
#   `ssh sybase\@cpiq 'scp -r /opt/sybase/cron_scripts/\* sybase\@cpdb2:/opt/sybase/db_backups/weekly/CPIQ/IQ_cron/'`;
   
# This is now a beginning of new tran log files too, so removing old ones from daily folders
#   `ssh cpdb2.canpar.com 'rm /opt/sybase/db_backups/\*/\*.tran\*'`;
# Also remove the files with no read permissions for bexec
#   `ssh cpdb2.canpar.com 'rm -fr /opt/sybase/db_backups/weekly/CPDB1/ASE_cron/nohup.out /opt/sybase/db_backups/weekly/CPDB1/ASE_cron/passwords'`;
#   `ssh cpdb2.canpar.com 'rm -fr /opt/sybase/db_backups/weekly/CPDB2/ASE_cron/getpass.pl'`;
#   `ssh cpdb2.canpar.com 'rm -fr /opt/sybase/db_backups/weekly/CPDB1/ASE_cron/getpass.pl'`;
#   `ssh cpdb2.canpar.com 'rm -fr /opt/sybase/db_backups/weekly/CPDB1/ASA_cron/cron_logs'`;
#   `ssh cpdb2.canpar.com 'rm -fr /opt/sybase/db_backups/weekly/CPDB1/ASE_cron/cron_logs'`;
}

if ($database eq "master"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe11/master.dmp`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database master to "/opt/sybase/db_backups/stripe11/master.dmp"
go
select "Dump of master finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
if ($dumptype eq "dumponly") {
	die "The $database has been dumped only\n";
}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/master.dmp sybase\@$standbyserver:/opt/sybase/db_backups/stripe11/
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after master scp that started on $currTime
$scpError
EOF
`;
   }
}else{
   print "Dump Process Failed\!\!\n";
   print "Messages From Database Dump Process...\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`; 

}#eof of failure
}#end of if db = master

if ($database eq "cdpvkm"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating SCP At:".localtime()."***\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/cdpvkm.dmp sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after cdpvkm scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver cdpvkm $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = cdpvkm

if ($database eq "lmscan"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating SCP At:".localtime()."***\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/lmscan.dmp sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after lmscan scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver lmscan $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = lmscan

if ($database eq "cmf_data_lm"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating SCP At:".localtime()."***\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/cmf_data_lm.dmp sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after cmf_data_lm scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver cmf_data_lm $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = cmf_data_lm

if ($database eq "rev_hist_lm"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating SCP At:".localtime()."***\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/rev_hist_lm.dmp sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after rev_hist_lm scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver rev_hist_lm $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = rev_hist_lm



if ($database eq "cpscan"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating Dump At:".localtime()."***\n";
   $currTime = localtime();

$scpError=`scp -p /opt/sybase/db_backups/stripe11/cpscan.dmp1 sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
scp -p /opt/sybase/db_backups/stripe12/cpscan.dmp2 sybase\@$ipaddress:/opt/sybase/db_backups/stripe12/ &
scp -p /opt/sybase/db_backups/stripe13/cpscan.dmp3 sybase\@$ipaddress:/opt/sybase/db_backups/stripe13/ &
scp -p /opt/sybase/db_backups/stripe14/cpscan.dmp4 sybase\@$ipaddress:/opt/sybase/db_backups/stripe14/ &
scp -p /opt/sybase/db_backups/stripe15/cpscan.dmp1a sybase\@$ipaddress:/opt/sybase/db_backups/stripe15/ &
scp -p /opt/sybase/db_backups/stripe17/cpscan.dmp3a sybase\@$ipaddress:/opt/sybase/db_backups/stripe17/ &
scp -p /opt/sybase/db_backups/stripe18/cpscan.dmp4a sybase\@$ipaddress:/opt/sybase/db_backups/stripe18/ &
scp -p /opt/sybase/db_backups/stripe15/cpscan.dmp1b sybase\@$ipaddress:/opt/sybase/db_backups/stripe15/ &
scp -p /opt/sybase/db_backups/stripe16/cpscan.dmp2b sybase\@$ipaddress:/opt/sybase/db_backups/stripe16/ &
scp -p /opt/sybase/db_backups/stripe17/cpscan.dmp3b sybase\@$ipaddress:/opt/sybase/db_backups/stripe17/ &
scp -p /opt/sybase/db_backups/stripe18/cpscan.dmp4b sybase\@$ipaddress:/opt/sybase/db_backups/stripe18/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after cpscan scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver cpscan $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList1\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = cpscan

if ($database eq "rev_hist"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating Dump At:".localtime()."***\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/rev_hist.dmp1 sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
scp -p /opt/sybase/db_backups/stripe12/rev_hist.dmp2 sybase\@$ipaddress:/opt/sybase/db_backups/stripe12/ &
scp -p /opt/sybase/db_backups/stripe13/rev_hist.dmp3 sybase\@$ipaddress:/opt/sybase/db_backups/stripe13/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after rev_hist scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver rev_hist $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList1\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = rev_hist



if ($database eq "arch_db"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe11/arch_db.dmp1 /opt/sybase/db_backups/stripe12/arch_db.dmp2 /opt/sybase/db_backups/stripe13/arch_db.dmp3`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database arch_db to "/opt/sybase/db_backups/stripe11/arch_db.dmp1"
stripe on "/opt/sybase/db_backups/stripe12/arch_db.dmp2"
stripe on "/opt/sybase/db_backups/stripe13/arch_db.dmp3"
with compression = 4
go
select "Dump of arch_db finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#       die "The $database has been dumped only\n";
#}
#check for errors and then start scp...

#$dumpError='complete'; 
# Remove the about line once arch_db tested
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/arch_db.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe11/ &
scp -p /opt/sybase/db_backups/stripe12/arch_db.dmp2 sybase\@$standbyserver:/opt/sybase/db_backups/stripe12/ &
scp -p /opt/sybase/db_backups/stripe13/arch_db.dmp3 sybase\@$standbyserver:/opt/sybase/db_backups/stripe13/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after arch_db scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver arch_db $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }else{
#                  print "Starting IQ load of $database at ".localtime()."...\n\n";
#                  $sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/load_rev_hist.pl $standbyserver > /opt/sybase/cron_scripts/cron_logs/load_rev_hist.log 2>\&1'`;
#                  print "$sshIQError\n";
            }
         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = arch_db

if ($database eq "mpr_data"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe11/mpr_data.dmp1 /opt/sybase/db_backups/stripe12/mpr_data.dmp2 /opt/sybase/db_backups/stripe13/mpr_data.dmp3`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database mpr_data to "/opt/sybase/db_backups/stripe11/mpr_data.dmp1"
stripe on "/opt/sybase/db_backups/stripe12/mpr_data.dmp2"
stripe on "/opt/sybase/db_backups/stripe13/mpr_data.dmp3"
with compression = 4
go
select "Dump of mpr_data finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#       die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/mpr_data.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe11/ &
scp -p /opt/sybase/db_backups/stripe12/mpr_data.dmp2 sybase\@$standbyserver:/opt/sybase/db_backups/stripe12/ &
scp -p /opt/sybase/db_backups/stripe13/mpr_data.dmp3 sybase\@$standbyserver:/opt/sybase/db_backups/stripe13/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after mpr_data scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver mpr_data $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }else{
#                  print "Starting IQ load of $database at ".localtime()."...\n\n";
#                  $sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/.pl $standbyserver > /opt/sybase/cron_scripts/cron_logs/load_rev_hist.log 2>\&1'`;
#                  print "$sshIQError\n";
            }
         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = mpr_data



if ($database eq "cmf_data"){

print "\n###scp Database:$database from Server:$standbyserver on Host:".`hostname`."###\n";


print "***Initiating Dump At:".localtime()."***\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/cmf_data.dmp1 sybase\@$ipaddress:/opt/sybase/db_backups/stripe11/ &
scp -p /opt/sybase/db_backups/stripe12/cmf_data.dmp2 sybase\@$ipaddress:/opt/sybase/db_backups/stripe12/ &
scp -p /opt/sybase/db_backups/stripe13/cmf_data.dmp3 sybase\@$ipaddress:/opt/sybase/db_backups/stripe13/ &
scp -p /opt/sybase/db_backups/stripe14/cmf_data.dmp4 sybase\@$ipaddress:/opt/sybase/db_backups/stripe14/ &
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after cmf_data scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }

            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $ipaddress /opt/sybase/cron_scripts/load_db.pl $testserver cmf_data $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList1\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }
         }

}#end of if db = cmf_data

if ($database eq "canship_webdb"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe14/canship_webdb.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database canship_webdb to "/opt/sybase/db_backups/stripe14/canship_webdb.dmp1"
with compression = 4
go
select "Dump of canship_webdb finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#	die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe14/canship_webdb.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe14/
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after canship_webdb scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
          if ($dumptype eq "dumponly") {
           die "The $database has been dumped only\n";
           }         
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver canship_webdb $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = canship_webdb


if ($database eq "canada_post"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe14/canada_post.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database canada_post to "/opt/sybase/db_backups/stripe14/canada_post.dmp1"
with compression = 4
go
select "Dump of canada_post finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#	die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe14/canada_post.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe14/
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after canada_post scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver canada_post $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = canada_post

if ($database eq "eput_db"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe14/eput_db.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database eput_db to "/opt/sybase/db_backups/stripe14/eput_db.dmp1"
with compression = 4
go
select "Dump of eput_db finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#	die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe14/eput.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe14/
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after eput scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
           die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver eput $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = eput

if ($database eq "liberty_db"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe14/liberty_db.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database liberty_db to "/opt/sybase/db_backups/stripe14/liberty_db.dmp1"
with compression = 4
go
select "Dump of liberty_db finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#	die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe14/liberty_db.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe14/
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after liberty_db scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver liberty_db $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = liberty_db

##############################   Script for cp_timesheet

if ($database eq "cp_timesheet"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe19/cp_timesheet.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database cp_timesheet to "/opt/sybase/db_backups/stripe19/cp_timesheet.dmp1"
with compression = 4
go
select "Dump of cp_timesheet finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#if ($dumptype eq "dumponly") {
#	die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe19/cp_timesheet.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe19/
`;
   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after cp_timesheet scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            } 
           print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver cp_timesheet $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = cp_timesheet

##############################   Script for us_ship

if ($database eq "us_ship"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe19/us_ship.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database us_ship to "/opt/sybase/db_backups/stripe19/us_ship.dmp1"
with compression = 4
go
select "Dump of us_ship finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

if ($dumptype eq "dumponly") {
	die "The $database has been dumped only\n";
}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe19/us_ship.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe19/
`;
  print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after us_ship scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver us_ship $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;
}#eof of scp process
}#end of if db = us_ship

##############################   Script for rate_update

if ($database eq "rate_update"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe19/rate_update.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database rate_update to "/opt/sybase/db_backups/stripe19/rate_update.dmp1"
with compression = 4
go
select "Dump of rate_update finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#if ($dumptype eq "dumponly") {
#        die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe19/rate_update.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe19/
`;
  print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after rate_update scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver rate_update $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;
}#eof of scp process
}#end of if db = rate_update

##############################   Script for collectpickup

if ($database eq "collectpickup"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe14/collectpickup.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database collectpickup to "/opt/sybase/db_backups/stripe14/collectpickup.dmp1"
with compression = 4
go
select "Dump of collectpickup finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#if ($dumptype eq "dumponly") {
#        die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe14/collectpickup.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe14/
`;
  print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after collectpickup scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver collectpickup $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;
}#eof of scp process
}#end of if db = collectpickup


##############################   Script for canshipws

if ($database eq "canshipws"){
print "\n###dumping Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe14/canshipws.dmp1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump database canshipws to "/opt/sybase/db_backups/stripe14/canshipws.dmp1"
with compression = 4
go
select "Dump of canshipws finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#if ($dumptype eq "dumponly") {
#        die "The $database has been dumped only\n";
#}
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe14/canshipws.dmp1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe14/
`;
  print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - SCP FOR DATABASE DUMP: $database

Following status was received after canshipws scp that started on $currTime
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
            die "The $database has been dumped only\n";
            }
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver canshipws $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Dump Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;
}#eof of scp process
}#end of if db = canshipws

#The Following line marks the end in the log file, leave at the bottom of this file
print "************************\nEnd of log at ".localtime()." ******************************\n\n";
