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
#10/12/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
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

#Do not run on Sundays, since we have archival processes running, that are blocking for a limited time...
$wday=sprintf('%02d',((localtime())[6]));

if ($wday == 0){
 die "Not running on Saturdays \n";
}

#Execute monitor now 

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
set rowcount 1
select '|',s1.spid,'|',s2.spid,'|',suser_name(s1.suid) blocked_user,'|',suser_name(s2.suid) blocking_user,'|',s1.time_blocked
from sysprocesses s1, sysprocesses s2 where s1.status = 'lock sleep' and s1.time_blocked > 300
and s2.spid = s1.blocked
go
exit
EOF
`;
print $error."\n";

$error =~ s/\s//g;
$error =~ s/\t//g;
@list = split(/\|/,$error);
$spid1 = $list[1];
$spid2 = $list[2];
$user1 = $list[3];
$user2 = $list[4];
$blocked = ($list[5]/60);

if ($list[5] > 300){
print "User $list[3] is being blocked by $list[4] for ".($list[5]/60)." minutes\n";
#`echo '$error' > /tmp/monitor_blocks`;

   $error2 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b -w400<<EOF 2>&1
dbcc traceon(3604)
go
dbcc sqltext($spid1)
go
select "========== Here is the showplan ============"
go
sp_showplan $spid1
go
select "****************************************************"
go    
dbcc sqltext($spid2)
go
select "========== Here is the showplan ============"
go
sp_showplan $spid2
go
dbcc traceoff(3604)
go
exit
EOF
`;

print $error2;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Blocking Found!!!

User $list[3] is being blocked by $list[4] for $blocked minutes
*****
Further Info about processes
*****
$error2
*****
EOF
`;
}

if ($list[5] > 1800){
print "User $list[3] is being blocked by $list[4] for ".($list[5]/60)." minutes\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Blocking Found In Sybase Server $prodserver !!!

User $list[1] is being blocked by $list[2] for $blocked minutes
Please Call Amer K At (647)321-1370 or Robbie Toyota at (289)541-5093 or Rafael at (416)434-2251 

EOF
`;
}

