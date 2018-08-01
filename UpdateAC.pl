#!/usr/bin/perl -w

###################################################################################
#Script:   This script updates ACprocessing information in liberty_db             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#04/18/05	Amer Khan	Originally created                                #
#                                                                                 #
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
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
   print "Usage:UpdateAC.pl\n";

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars
$database = "liberty_db";

#Execute update now

print "\n###Running update on Database:$database from Server:$prodserver on Host:".`hostname`."###\n";


print "***Initiating update At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use $database
go
execute UpdateAC
go
exit
EOF
`;
print "$error\n";
   if ($error =~ /not/){
      print "Messages From UpdateAC...\n";
      print "$error\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: UpdateAC

$error
EOF
`;
   }#end of if messages received

