#!/usr/bin/perl -w

###################################################################################
#Script:   This script increase the data size of a sybase database                #
#          Also, extend the segments                                              #
#          Added DBA's to email                                                   #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#08/27/04	Amer Khan	Originally created                                #
#                                                                                 #
#02/22/06       Ahsan Ahmed                                                       #
###################################################################################

#Usage Restrictions
if ($#ARGV < 3){
   print "\n\nUsage: increase_db_size.pl servername dbname devicename size(in MB) [segment name]\n";
   print "\n\nExample: increase_db_size.pl CPDB1 cpscan vg22_data_dev11 200 [myseg]\n";
   die "\n\nScript Executed With Wrong Number Of Arguments\n\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];
$devname = $ARGV[2];
$size = $ARGV[3];
$segmentname = $ARGV[4];

if ($segmentname =~ /^\n/ || $segmentname =~ /^\s/ || $segmentname eq ''){
    $segmentname = 'default';
}

#Execute db increase based on database name provided

print "\n###Running runcheck on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating db increase At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
USE master
go
ALTER DATABASE $database
ON $devname = $size
go
exit
EOF
`;
   if ($error =~ /Msg/ || $error ne ''){
      print "Messages...\n";
      print "$error\n";
}

$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
USE $database
go
EXEC sp_dropsegment \'default\', \'$database\',\'$devname\'
go
EXEC sp_extendsegment \'$segmentname\',\'$database\',\'$devname\'
go
EXEC sp_dropsegment \'system\', \'$database\',\'$devname\'
go
exit
EOF
`;
if ($error =~ /Msg/ || $error ne ''){
      print "Messages...\n";
      print "$error\n";
}

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: DB Size Increased: $database
In Server: $server DB: $database Added device $devname with size: $size to segment: $segmentname

$error
EOF
`;

