#!/usr/bin/perl -w

###################################################################################
#Script:   This script keeps track of the database growth and percent increase in #
#          db size from the last reading taken                                    #
#                                                                                 #
#Note:     This script can be used with any database, but you have to have a table#
#          called db_growth_record in the database where it is being executed     #
#	   Sends email to DBA's if there are problems				  #
#Author:   Amer Khan                                                              #
#Revision: 1                                                                       #
#Date	Feb 21,06	Name Ahsan Ahmed    Description Added comments & email    #
#---------------------------------------------------------------------------------#
#02/03/04	Amer Khan	Originally created                                #
#09/01/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################

open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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
#Usage Restrictions
if ($#ARGV != 0){
   print "Usage: db_growth.pl cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$database = $ARGV[0];

#Execute db_growth based on database name provided

print "\n###Running db_growth on Database:$database from Server:$prodserver on Host:".`hostname`."###\n";


print "***Initiating db_growth At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver -b -n<<EOF 2>&1
set nocount on
go
use $database
go
sp__dbspace
go
exit
EOF
`;

print $sqlError;

#print "@spid\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "Messages From db growth for $database...\n";
      print "$sqlError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: DB Growth: $database

Following status was received after $database db growth on \`date\`
$sqlError
EOF
`;
   }#end of if messages received
