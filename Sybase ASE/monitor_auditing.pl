#!/usr/bin/perl -w

###################################################################################
#Script:   This script keeps track of auditing in cpscan, if new audit records are#
#          added to the sysaudits tables, it sends a page                         #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#11/23/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: monitor_auditing.pl CPDATA1 sybsecurity \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Count the number of rows in sysaudits_01 before paging
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -b -n<<EOF 2>&1
set nocount on
go
use $database
go
select count(*) from sysaudits_01
go
exit
EOF
`;

$sqlError =~ s/\s//g;

#If number of rows is > 1, then we do have audit event to report, get the rest of info now
if ($sqlError > 1){
$sqlError1 = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -n -w200<<EOF 2>&1
set nocount on
go
use $database
go
select * from sysaudits_01
go
exit
EOF
`;
}

print "$sqlError1\n";

   if ($sqlError > 1){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Auditing Event Found @ \`date\`

$sqlError1
EOF
`;
   }#end of if messages received

# Now the message has been sent, delete the rows from the sysaudits_01 to avoid page again the next hour

$sqlError1 = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -n -w200<<EOF 2>&1
set nocount on
go
use $database
go
truncate table sysaudits_01
go
exit
EOF
`;

