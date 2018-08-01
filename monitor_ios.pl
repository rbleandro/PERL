#!/usr/bin/perl

###################################################################################
#Script:   This script monitors IOS over 1000000                                  #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod") or die "Can't open < /opt/sap/cron_scripts/passwords/check_prod : $!";
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

#Setting Sybase environment is set properly

#Initialize vars

#Cleanup previous files...
$startHour=sprintf('%02d',((localtime())[2]));

if ($startHour eq '14'){
   `cd /tmp
ls \| grep \^io_\* \| xargs rm`;
}


#Execute IO Monitoring 

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
set rowcount 1
select '|',physical_io,'|',suser_name(suid),'|',spid,'|',program_name,'|',clientapplname,'|',clientname
from sysprocesses where physical_io > 100000 and suid > 0 and status <> 'recv sleep' and suser_name(suid) not in ('sa','cwmaint','sybmaint','backup','ops3','ops1','DBA','crystal_reporter')
--from sysprocesses where physical_io > 300000 and suid > 0 and status <> 'recv sleep'
go
exit
EOF
`;

print $error;

$error =~ s/\s//g;
$error =~ s/\t//g;
@list = split(/\|/,$error);
$io = $list[1];
$user = $list[2];
$spid = $list[3];

print "Here is the io: $io and name: $user spid:$spid \n";
if ($io > 100000){
   print "Large IO found by $user\n";
   $error2 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b -w400<<EOF 2>&1
dbcc traceon(3604)
go
dbcc sqltext($spid)
go
dbcc traceoff(3604)
go
sp_showplan $spid
go
exit
EOF
`;

print $error2;

@sql = split(/SQL Text:/,$error2);

@final_sql = split(/DBCC/,$sql[1]);

$showSQL = $final_sql[0];

print "SQL RAN: $showSQL \n";

   if (-e "/tmp/io_$user"){ }
   else{
      `touch /tmp/io_$user`;
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Large IO Detected By $user!!!

Large IO: $io found by $user
******
$error
******
SQL RAN:
$error2
******
EOF
`;
}
   }


