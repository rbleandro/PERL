#!/usr/bin/perl -w

###################################################################################
#Script:   This script loads the data into handheld db for individual terminals   #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#06/26/2006	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
   print "Usage:UpdateAC.pl\n";

#Initialize vars
$server = $ARGV[0];
$terminal = $ARGV[1];
$ip_add	= $ARGV[2];

#Execute setup now

print "\n###Running setup on Database:cpscan from Server:$server on Host:".`hostname`."###\n";


print "***Initiating setup At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server <<EOF 2>&1
use cpscan
go
execute pre_pop_handheld \"$terminal\"
go
exit
EOF
`;
print "$error\n";

$asa_error = `/opt/sybase/DBISQL/bin/dbisql -c "uid=dba;pwd=sql" -host $ip_add -port 2638 -nogui /opt/sybase/cron_scripts/sql/alter_event_connect_trg.sql`;

print "$asa_error\n";
die;
   if ($error =~ /not/){
      print "Messages From UpdateAC...\n";
      print "$error\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: UpdateAC

$error
EOF
`;
   }#end of if messages received

