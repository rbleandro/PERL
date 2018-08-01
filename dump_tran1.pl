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
###################################################################################

#Usage Restrictions
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

print "\n###dumping Transaction Database:$database from Server:$prodserver on Host:".`hostname`."###\n";

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
            print "Starting load on $standbyserver through ssh...\n\n";
            $sshError = `ssh $standbyserver /opt/sybase/cron_scripts/load_db.pl $standbyserver rev_hist $startDay $startHour $startMin`;
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

