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
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: dump_tran.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

die "die";
#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Set starting variable
$startDay=sprintf('%02d',((localtime())[6]));
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

use POSIX qw(strftime);
$currDay = lc(strftime "%A", localtime);

#Set the name of the tran file based on incoming params
$tranFile = $database."_".$startHour."_".$startMin;

#Execute dump command based on database name provided

if ($currDay eq "monday" && $database eq "rev_hist"){
   `ssh cpdb2.canpar.com 'rm /opt/sybase/db_backups/weekly/*`;
}

if ($database eq "cpscan"){
print "\n###dumping Database:$database from Server:$server on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
if($startHour eq '07' && $startMin eq '00'){
`rm /opt/sybase/db_backups/stripe17/cpscan*.tran1 /opt/sybase/db_backups/stripe18/cpscan*.tran2 /opt/sybase/db_backups/stripe19/cpscan*.tran2`;
}
print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
dump tran cpscan to "compress::2::/opt/sybase/db_backups/stripe17/$tranFile.tran1"
stripe on "compress::2::/opt/sybase/db_backups/stripe18/$tranFile.tran2"
stripe on "compress::2::/opt/sybase/db_backups/stripe19/$tranFile.tran3"
with standby_access
go
select "Dump of cpscan finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;
print "$dumpError\n";

#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Transaction Dump was successful, starting scp process at ".localtime()."\n\n";
$scpError=`scp -p /opt/sybase/db_backups/stripe17/$tranFile.tran1 sybase\@cpdb2.canpar.com:/opt/sybase/db_backups/stripe17/ &
scp -p /opt/sybase/db_backups/stripe18/$tranFile.tran2 sybase\@cpdb2.canpar.com:/opt/sybase/db_backups/stripe18/ &
scp -p /opt/sybase/db_backups/stripe19/$tranFile.tran2 sybase\@cpdb2.canpar.com:/opt/sybase/db_backups/stripe19/ &
`;

   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: ERROR - SCP FOR TRANSACTION DUMP: $database

$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            print "Starting load on cpdb2 through ssh...\n\n";
            $sshError = `ssh cpdb2.canpar.com /opt/sybase/cron_scripts/load_tran.pl CPDATA2 cpscan $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: ERROR - TRANSACTION LOAD : $database

$sshError
EOF
`;
            }else{
`;
            }else{
            }else{
#                  print "Starting IQ load of $database at ".localtime()."...\n\n";
#                  $sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/load_cpscan.pl CPDATA2 0 > /opt/sybase/cron_scripts/cron_logs/load_cpscan.log 2>\&1'`;
                  print "$sshIQError\n";
            }

         }
}else{
   print "Transaction Load for $database FAILED!!!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - TRANSACTION DUMP: $database

$dumpError
EOF
`;


}#eof of failure

}#end of if db = cpscan

if ($database eq "rev_hist"){
print "\n###dumping Database:$database from Server:$server on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe11/rev_hist*.tran1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
dump tran rev_hist to "compress::2::/opt/sybase/db_backups/stripe11/$tranFile.tran1"
with standby_access
go
select "Dump of rev_hist finished at "+ convert(varchar,getdate(),109)
go
exit
EOF
`;

#check for errors and then start scp...
if($dumpError =~ /complete/){
   print "Transaction Dump was successful, starting scp process at ".localtime()."\n\n";
$scpError=`scp -p /opt/sybase/db_backups/stripe11/$tranFile.tran1 sybase\@cpdb2.canpar.com:/opt/sybase/db_backups/stripe11/
`;

   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: ERROR - SCP FOR TRANSACTION DUMP: $database

Following status was received after rev_hist scp on \`date\`
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            print "Starting load on cpdb2 through ssh...\n\n";
            $sshError = `ssh cpdb2.canpar.com /opt/sybase/cron_scripts/load_tran.pl CPDATA2 rev_hist $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: ERROR - TRANSACTION LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }else{
                  print "Starting IQ load of $database at ".localtime()."...\n\n";
                  $sshIQError = `ssh cpiq '/opt/sybase/cron_scripts/load_rev_hist.pl CPDATA1 > /opt/sybase/cron_scripts/cron_logs/load_rev_hist.log 2>\&1'`;
                  print "$sshIQError\n";
            }

         }
}else{
   print "Transaction Load for $database FAILED!!!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: ERROR - TRANSACTION DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of failure
}#end of if db = rev_hist

if ($database eq "cmf_data"){
print "\n###dumping Database:$database from Server:$server on Host:".`hostname`."###\n";

print "\n***Removing existing dumps from directories...***\n";
`rm /opt/sybase/db_backups/stripe11/cmf_data*.tran1`;

print "***Initiating Dump At:".localtime()."***\n";
$dumpError = `. /opt/sybase/SYBASE.sh
isql -Ubackup -P\`/opt/sybase/cron_scripts/getpass.pl backup\` -S$server <<EOF 2>&1
dump tran $database to "compress::2::/opt/sybase/db_backups/stripe11/$tranFile.tran1"
with standby_access
go
select "Dump of $database finished at "+ convert(varchar,getdate(),109)
go
exit
   print "Transaction Dump was successful, starting scp process at ".localtime()."\n\n";
$scpError=`scp -p /opt/sybase/db_backups/stripe11/$tranFile.tran1 sybase\@cpdb2.canpar.com:/opt/sybase/db_backups/stripe11/
`;

   print $scpError."\n";

   if($scpError =~ /no|not/){
      print "Errors may have occurred during scp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - SCP FOR TRANSACTION DUMP: $database

Following status was received after cmf_data scp on \`date\`
$scpError
EOF
`;
   }else{
            print "scp succeeded!!\n\n";
            print "Starting load on cpdb2 through ssh...\n\n";
            $sshError = `ssh cpdb2.canpar.com /opt/sybase/cron_scripts/load_tran.pl CPDATA2 cmf_data $startDay $startHour $startMin`;
            print $sshError."\n\n";
            if($sshError =~ /Failed/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: ERROR - TRANSACTION LOAD : $database

Following messages were received after ssh load attempt
$sshError
EOF
`;
            }

         }
}else{
   print "Transaction Load for $database FAILED!!!\n";
   print "$dumpError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: ERROR - TRANSACTION DUMP: $database

Following status was received after $database dump that started on $currTime
$dumpError
EOF
`;

}#eof of failure
}#end of if db = cmf_data



#The Following line marks the end in the log file, leave at the bottom of this file
print "************************\nEnd of log at ".localtime()." ******************************\n\n";
