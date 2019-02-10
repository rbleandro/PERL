#!/usr/bin/perl

#Script:   This script monitors any blocking that exists for over 3 seconds for database svp_cp. 
#Author:   Rafael Bahia
#Version history:
#Dec 13 2018#Rafael Leandro#Originally created

#open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
#while (<PROD>){
#@prodline = split(/\t/, $_);
#$prodline[1] =~ s/\n//g;
#}
#if ($prodline[1] eq "0" ){
#print "standby server \n";
#        die "This is a stand by server\n"
#}
#use Sys::Hostname;
#$prodserver = hostname();

#$my_pid = getppid();
#$isProcessRunning =`ps -ef|grep sybase|grep monitor_blocks_svp.pl|grep -v grep|grep -v $my_pid|grep -v "vim monitor_blocks_svp.pl"|grep -v "less monitor_blocks_svp.pl"`;
#
##print "My pid: $my_pid\n";
#print "Running: $isProcessRunning \n";
#
#if ($isProcessRunning){
#die "\n Can not run, previous process is still running \n";
#
#}else{
#print "No Previous process is running, continuing\n";
#}

#if ($prodserver =~ /cpsybtest/)
#{
#$prodserver = "CPSYBTEST";
#}
#Do not run on Sundays, since we have archival processes running, that are blocking for a limited time...
#$wday=sprintf('%02d',((localtime())[6]));
#
#if ($wday == 0){
# die "Not running on Saturdays \n";
#}

#Execute monitor now

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -SCPDB1 -n -b <<EOF 2>&1
set nocount on
set rowcount 1
select '|',s1.spid,'|',s2.spid,'|',suser_name(s1.suid) blocked_user,'|',suser_name(s2.suid) blocking_user,'|',s1.time_blocked
from sysprocesses s1, sysprocesses s2 where s1.status = 'lock sleep' and s1.time_blocked > 3
and s2.spid = s1.blocked
and DB_NAME(s1.dbid) = 'svp_cp'
go
exit
EOF
`;
print $error."\n";

if($error =~ /no|not|Msg/)
{
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: ERROR - monitor_blocks_svp script (get current blocks phase).
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
$blocked = $list[5];

if ($list[5] > 4){
print "User $list[3] is being blocked by $list[4] for more then 5 seconds\n";
#`echo '$error' > /tmp/monitor_blocks`;

   $error2 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -SCPDB1 -n -b -w400<<EOF 2>&1
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
To: rleandro\@canpar.com
Subject: ERROR - monitor_blocks_svp script(get execution plans phase).
$error2
EOF
`;
die "Email sent";
}

print $error2;

`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: Blocking Found!!!

User $list[3] is being blocked by $list[4] for $blocked seconds
*****
Further Info about processes
*****
$error2
*****
EOF
`;
}

