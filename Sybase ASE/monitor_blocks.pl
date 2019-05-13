#!/usr/bin/perl

#Script:   This script monitors any blocking that exists for over 5 minutes
#          or any blocks caused by sleeping processes with open transactions for
#          more than 10 seconds  #
#Author:   Amer Khan
#Revision:
#Date		Name			Description
#---------------------------------------------------------------------------------
#05/04/05	Amer Khan		Originally created
#10/12/07   Ahsan Ahmed     Modified
#11/07/18   Rafael Leandro  Modified. Formating ajustments.
#14/12/18   Rafael Leandro  Modified. Added automatic kill for phantom processes blocking for more than 10 minutes.

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

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}
#Do not run on Sundays, since we have archival processes running, that are blocking for a limited time...
$wday=sprintf('%02d',((localtime())[6]));

#if ($wday == 0){
# die "Not running on Saturdays \n";
#}

#Execute monitor now

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
set rowcount 1
select '|',s1.spid,'|',s2.spid,'|',suser_name(s1.suid) blocked_user,'|',suser_name(s2.suid) blocking_user,'|',s1.time_blocked
from sysprocesses s1, sysprocesses s2 where s1.status = 'lock sleep' and s1.time_blocked > 300
and s2.spid = s1.blocked
union
select '|',s1.spid,'|',s2.spid,'|',suser_name(s1.suid) blocked_user,'|',suser_name(s2.suid) blocking_user,'|',s1.time_blocked
from sysprocesses s1, sysprocesses s2
where s1.status = 'lock sleep' and s1.time_blocked > 10
and s2.spid = s1.blocked
and s2.status = 'recv sleep'
go
exit
EOF
`;
print $error."\n";

if($error =~ /no|not|Msg/)
{
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_blocks script (get current blocks phase).
$error
EOF
`;
die "Email sent";
}

$error =~ s/\s//g;
$error =~ s/\t//g;
@list = split(/\|/,$error);
$spid1 = $list[1];
$spid2 = $list[2];
$user1 = $list[3];
$user2 = $list[4];
$blocked = ($list[5]/60);

if ($list[5] > 10){
print "User $list[3] is being blocked by $list[4] for ".($list[5]/60)." minutes (if the duration is less than 5 minutes it could indicate open transactions in the database)\n";
#`echo '$error' > /tmp/monitor_blocks`;

   $error2 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b -w400<<EOF 2>&1
dbcc traceon(3604)
go
select "***********************THIS IS THE QUERY BLOCKED*****************************"
go
dbcc sqltext($spid1)
go
select "========== Here is the showplan for the blocked query ============"
go
sp_showplan $spid1
go
select "***********************THIS IS THE BLOCKING QUERY*****************************"
go
dbcc sqltext($spid2)
go
select "========== Here is the showplan for the blocking query ============"
go
sp_showplan $spid2
go
dbcc traceoff(3604)
go
exit
EOF
`;

if($error2 =~ /Msg/)
{
print $error2;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_blocks script(get execution plans phase).
$error2
EOF
`;
die "Email sent";
}

print $error2;

if($error2 =~ /Possibly the query has not started or has finished executing/ && $list[5] > 600)
{
$error3 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
kill $spid2
go
exit
EOF
`;

if($error3 =~ /no|not|Msg/)
{
print $error3;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_blocks script(kill phase).
$error3
EOF
`;
die "Email sent";
}


`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Blocking Found!!!

User $list[3] was being blocked by $list[4] for $blocked minutes. Spid $spid2 was killed automatically (phantom session with open transaction but no execution plan). Further action should not be necessary.
*****
Further Info about processes
*****
$error2
*****
EOF
`;
}
else
{
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
}

#if ($list[5] > 1800){
#print "User $list[3] is being blocked by $list[4] for ".($list[5]/60)." minutes\n";
#
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
#Subject: Blocking Found In Sybase Server $prodserver !!!
#
#User $list[1] is being blocked by $list[2] for $blocked minutes
#Please Call Amer K At (647)321-1370 or Robbie Toyota at (289)541-5093 or Rafael at (416)434-2251
#
#EOF
#`;
#}

