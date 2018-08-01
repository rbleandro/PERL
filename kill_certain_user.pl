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
#01/19/04	Amer Khan	Modified to be used with all dbs		  #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 2){
   print "Usage: kill_processes.pl CPDB1 cpscan john_doe\n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];
$username = $ARGV[2];

#Execute kill_processes based on database name provided

print "\n###Running kill_processes on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating kill_processes At:".localtime()."***\n";
$getSpids = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -b -n<<EOF 2>&1
set nocount on
go
select spid from master..sysprocesses where suser_name(suid) = "$username"
go
exit
EOF
`;

@spid = split(/\n/,$getSpids);
$i = 0;
$sqlError = "";
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
#print "@spid\n";
   if ($sqlError =~ /Msg/){
      print "Messages From Kill Process...\n";
      print "$getSpids\n";
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: $database Kill Process Status

#Following status was received after $database Kill process on \`date\`
#$sqlError
#EOF
#`;
   }#end of if messages received


#check for errors ...
#   if($sqlError =~ /User/){
#   print "$database kill process was successful at ".localtime()."\n\n";
#
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: $database Kill process Status
#
#Following status was received after $database kill process on \`date\`
#$sqlError
#EOF
#`;
#
#   }#eof of kill process errors

