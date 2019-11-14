#!/usr/bin/perl

#Script:   	This script monitors process memory usage. Anything above the baseline generates an
#			alert
#Author:   	Amer Khan
#Revision:
#Date			Name			Description
#---------------------------------------------------------------------------------
#June 18 2019	Rafael Leandro	Originally created
#July 5 2019	Rafael Leandro	Removed day execution restrictions

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
select sum(memusage)
from sysprocesses
where 1=1
go
exit
EOF
`;

if($error =~ /no|not|Msg/)
{
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_memory_usage script.
$error
EOF
`;
die "Email sent";
}

$error =~ s/\s//g;
$error =~ s/\t//g;

print $error."\n";

if ($error > 300000){

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Process memory alert!!!

Total memory usage in Sybase crossed the baseline. This can cause resource starvation and lead to connection problems for new processes trying to logon to the databases. Please check ASAP.

This is script is located at /opt/sap/cron_scripts/monitor_memory_usage.pl.

EOF
`;
}

