#!/usr/bin/perl

###################################################################################
#Script:   This script monitors IOS over 10000                                  #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage:monitor_ios.pl CPDATA1\n";
   die;
}
#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars
$server = $ARGV[0];

#Cleanup previous files...
$startHour=sprintf('%02d',((localtime())[2]));

if ($startHour eq '14'){
   `cd /tmp
ls \| grep \^io_\* \| xargs rm`;
}


#Execute IO Monitoring 

$error = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -n -b -s'|'<<EOF 2>&1
set nocount on
set rowcount 1
select physical_io,suser_name(suid),program_name,clientapplname,clientname,spid
from sysprocesses where physical_io > 10000 and suid > 0 and status <> 'recv sleep' and suser_name(suid) not in ('sa','cwmaint','sybmaint','backup','ops3','ops1')
go
exit
EOF
`;

print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$io = $list[1];
$user = $list[2];
$spid = $list[5];

#print "Here is the io: $io and name: $user \n";
if ($io > 10000){
   print "Large IO found by $user\n";
   $error2 = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -n -b -s'|'<<EOF 2>&1
dbcc traceon(3604)
go
dbcc sqltext\($spid\)
go
dbcc traceoff(3604)
go
exit
EOF
`;

   print $error2;

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


