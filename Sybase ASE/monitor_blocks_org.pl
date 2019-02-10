#!/usr/bin/perl

###################################################################################
#Script:   This script monitors any blocking that exists for over 5 minutes       #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#05/04/05	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage:monitor_blocks.pl CPDATA1\n";
   die;
}
#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars
$server = $ARGV[0];

#Execute monitor now 

$error = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -n -b -s'|'<<EOF 2>&1
set nocount on
set rowcount 1
select suser_name(s1.suid) blocked_user,suser_name(s2.suid) blocking_user,s1.time_blocked
from sysprocesses s1, sysprocesses s2 where s1.status = 'lock sleep' and s1.time_blocked > 300
and s2.spid = s1.blocked
go
exit
EOF
`;
#print $error."\n";
$error =~ s/\s//g;
@list = split(/\|/,$error);
$blocked = ($list[3]/60);
if ($list[3] > 300){
print "User $list[1] is being blocked by $list[2] for ".($list[3]/60)." minutes\n";
#`echo '$error' > /tmp/monitor_blocks`;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Blocking Found!!!

User $list[1] is being blocked by $list[2] for $blocked minutes
EOF
`;
}

if ($list[3] > 1800){
print "User $list[1] is being blocked by $list[2] for ".($list[3]/60)." minutes\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Blocking Found In Sybase Server CPDB2!!!

User $list[1] is being blocked by $list[2] for $blocked minutes
Please Call Amer At (647)321-1370 or Ahsan (416) 791-0577

EOF
`;
}

