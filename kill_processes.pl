#!/usr/bin/perl -w

###################################################################################
#Script:   This script kills all processes logged into the specified database, so #
#          that the load process can be initiated which requires every one to be  #
#          logged out of that database being loaded                               #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/30/03	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: kill_processes.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Execute kill_processes based on database name provided

print "\n###Running kill_processes on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating kill_processes At:".localtime()."***\n";
$getSpids = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -b -n<<EOF 2>&1
set nocount on
go
select spid from master..sysprocesses where db_name(dbid) = "$database"
go
exit
EOF
`;

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -b -n<<EOF 2>&1
set nocount on
go
select suser_name(suid) from master..sysprocesses where db_name(dbid) = "$database"
go
exit
EOF
`;
@users = split(/\n/,$sqlError);
@spid = split(/\n/,$getSpids);
$i = 0;
$sqlError = "";
print "Users logged in the $database, attempting to kill @users\n" if $#users > -1;

while ($i <= $#spid){
   $spid[$i] =~ s/\s//g;
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -b -n<<EOF 2>&1
set nocount on
go
select "User: "+suser_name(suid) from master..sysprocesses where spid=$spid[$i]
go
kill $spid[$i]
go
exit
EOF
`;
print "Killed: $spid[$i] $sqlError\n\n";

   $i++;

}
