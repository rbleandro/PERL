#!/usr/bin/perl -w

###################################################################################
#Script:   This script dumps different db transactions. All the sql and logic is  #
#          included in this script. Script is supposed to work with all databases.#
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/29/03	Amer Khan	Originally created                                #
#                                                                                 #
#02/21/06	Ahsan Ahmed	Added comments and email 
#06/02/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
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

#Usage Restrictions
if ($#ARGV > 1){
   print "Usage: dump_tran.pl cpscan optional (dumponly) \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

if ($dumptype eq "dumponly"){
        }else{
        if ($dumptype eq "dumpload"){
                }else{
                        die "Please enter the proper Argument (dumponly)\n";
        }
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";

#Store inputs
$database = $ARGV[0];

#Set starting variable
$startDay=sprintf('%02d',((localtime())[6]));
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

use POSIX qw(strftime);
$currDay = lc(strftime "%A", localtime);

#Set the name of the tran file based on incoming params
$tranFile = $database."_".$startDay."_".$startHour;

#Execute dump command based on database name provided

if ($currDay eq "monday" && $database eq "rev_hist"){
   `ssh $standbyserver.canpar.com 'rm /opt/sybase/db_backups/weekly/*`;
}

if ($database eq "cpscan"){
print "\n###dumping Transaction Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";

print "\nRemoving previsous tran files now...".localtime()."\n\n";
`rm /opt/sybase/db_backups/stripe17/$tranFile.tran1 /opt/sybase/db_backups/stripe18/$tranFile.tran2 /opt/sybase/db_backups/stripe19/$tranFile.tran3`;

print "Files removed...".localtime()."\n\n";
sleep(30);
print "slept for 30 sec...".localtime()."***\n";

$look = `ps -ef | grep rm | grep db_backups`;
print "Is rm files still running...".localtime()."***\n";

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump tran cpscan to "/opt/sybase/db_backups/stripe17/$tranFile.tran1"
stripe on "/opt/sybase/db_backups/stripe18/$tranFile.tran2"
stripe on "/opt/sybase/db_backups/stripe19/$tranFile.tran3"
with compression = 4
go

select "Dump of cpscan finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#check for errors and then start scp...
if($dumpError =~ /complete/){
   $currTime = localtime();
   print "Transaction Dump was successful, starting scp process at ".localtime()."\n\n";
$scpError=`scp -p /opt/sybase/db_backups/stripe17/$tranFile.tran1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe17/ &
scp -p /opt/sybase/db_backups/stripe18/$tranFile.tran2 sybase\@$standbyserver:/opt/sybase/db_backups/stripe18/ &
scp -p /opt/sybase/db_backups/stripe19/$tranFile.tran3 sybase\@$standbyserver:/opt/sybase/db_backups/stripe19/ &
`;

   print $scpError."\n";

   if($scpError =~ /completed/){ #/no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - SCP FOR TRANSACTION DATABASE DUMP: $database

Following status was received after cpscan scp that started on $currTime
$scpError
EOF
`;
die;
   }else{
            print "scp succeeded!!\n\n";
            if ($dumptype eq "dumponly") {
        die "The $database has been dumped only\n";
}
            print "Starting load on $standbyserver through ssh...\n\n";
#            $sshError = `ssh $standbyserver.canpar.com /opt/sybase/cron_scripts/load_tran.pl $standbyserver cpscan $startDay $startHour $startMin`;
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
                  print "Starting IQ load of $database at ".localtime()."...\n\n";
#                  $sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/load_cpscan.pl $prodserver 0 > /opt/sybase/cron_scripts/cron_logs/load_cpscan.log 2>\&1'`;
                  print "$sshIQError\n";
            }
         }
}else{
   print "Transaction Dump Process Failed\!\!\n";
   print "Messages From Database Dump Process...\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - TRANSACTION DATABASE DUMP: $database

-- $currTime --
$dumpError
EOF
`;

}#eof of failure


`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - TRANSACTION DATABASE DUMP: $database

-- $currTime --
Dump completed. $dumpError
EOF
`;

}#end of if db = cpscan


if ($database eq "rev_hist"){
print "\n###dumping Transaction Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

print "\n***Removing existing Transaction dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe11/$tranFile.tran1`;
print "***Initiating Transaction Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$prodserver <<EOF 2>&1
dump tran rev_hist to "/opt/sybase/db_backups/stripe11/$tranFile.tran1"
with compression = 4
go
select "Transaction Dump of rev_hist finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Transaction Dump was successful, starting scp process at ".localtime()."\n\n";
   $currTime = localtime();
$scpError=`scp -p /opt/sybase/db_backups/stripe11/$tranFile.tran1 sybase\@$standbyserver:/opt/sybase/db_backups/stripe11/
`;
   
print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - SCP FOR DATABASE TRANSACTION DUMP: $database

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
 #           $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver rev_hist $startDay $startHour $startMin`;
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
                  print "Starting IQ load of $database at ".localtime()."...\n\n";
#                  $sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/load_rev_hist.pl $standbyserver > /opt/sybase/cron_scripts/cron_logs/load_rev_hist.log 2>\&1'`;
                  print "$sshIQError\n";
            }
         }
}else{
   print "Dump Transaction Process Failed\!\!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - DATABASE TRANSACTION DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of scp process
}#end of if db = rev_hist

#The Following line marks the end in the log file, leave at the bottom of this file
print "************************\nEnd of log at ".localtime()." ******************************\n\n";
