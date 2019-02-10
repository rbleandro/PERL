#!/usr/bin/perl -w

###################################################################################
#Script:   This script increase the logsegment size of a sybase database          #
#          added email address for DBA's                                          #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#08/27/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV < 3){
   print "\n\nUsage: increase_log_size.pl servername dbname devicename size(in MB)\n";
   print "\n\nUsage: increase_log_size.pl CPDB1 cpscan vg22_data_dev11 200 \n";
   die "\nScript Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];
$devname = $ARGV[2];
$size = $ARGV[3];
$segmentname = 'logsegment';

if ($segmentname =~ /^\n/ || $segmentname =~ /^\s/ || $segmentname eq ''){
    $segmentname = 'default';
}

#Execute log increase based on database name provided

print "\n###Running log increase on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating log increase At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
USE master
go
ALTER DATABASE $database
LOG ON $devname = $size
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

