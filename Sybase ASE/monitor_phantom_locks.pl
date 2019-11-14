#!/usr/bin/perl

#Script:   		This script checks for phantom locks in Sybase that are pending release
#				This alert was created in response to kernel errors that happened every Sunday morning and left phantom locks in the database
#				The cause for the kernel error was figured out on July 28 2019. This script was still left in place just in case the problem 
#				repeats itself for some other reason.
#Author:   		Rafael Leandro
#Revision:
#Date			Name				Description
#-----------------------------------------------------------------------------------------
#July 5 2019	Rafael Leandro		Originally created

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

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select count(*) 
from master..syslocks s
where 1=1
and not exists(select * from master..sysprocesses p where p.spid=s.spid)
--leaving the below spid out because as of July 28 2019 it was orphaned due to kernel errors.
--please remove these lines after Sybase has been rebooted.
and s.spid<>385 
go
EOF
`;

if($error =~ /no|not|Msg/)
{
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_phantom_locks script.
$error
EOF
`;
die "Email sent";
}

$error =~ s/\s//g;
$error =~ s/\t//g;

print $error."\n";

if ($error > 0)
{
sleep(900); #sleeping for the specified amount of seconds. We only want to alert if the phantom record is persistent for more than that time.

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select count(*) 
from master..syslocks s
where 1=1
and not exists(select * from master..sysprocesses p where p.spid=s.spid)
--leaving the below spid out because as of July 28 2019 it was orphaned due to kernel errors.
--please remove these lines after Sybase has been rebooted.
and s.spid<>385
go
EOF
`;

if($error =~ /no|not|Msg/)
{
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_phantom_locks script.
$error
EOF
`;
die "Email sent";
}

$error =~ s/\s//g;
$error =~ s/\t//g;

if ($error > 0)
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Phantom locks alert!!!

Phantom locks were found in Sybase. Execute the query below and then use sp_lock and dbcc lock_release to get rid of the ghost locks.

select db_name(dbid),object_name(id),* 
from master..syslocks s
where 1=1
--and spid=1154 
and not exists(select * from sysprocesses p where spid=s.spid)

This is script is located at /opt/sap/cron_scripts/monitor_phantom_locks.pl.

EOF
`;
}

}