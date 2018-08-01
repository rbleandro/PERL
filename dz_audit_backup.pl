#!/usr/bin/perl -w

###################################################################################
#Script:   This script make dz_audit table backup from test to dev(cpsca)         #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#05/07/2013	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
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
$prodserver = "hqvsybtest";

#Setting Sybase environment is set properly

#require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Initialize vars
$database = "cpscan_test";

#Execute Backup now

print "\n###Running backup on Database:$database from Server:$prodserver on Host:".`hostname`."###\n";


print "***Initiating backup At:".localtime()."***\n";
$error = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use $database
go
execute dz_audit_backup
go
exit
EOF
`;
print "$error\n";
   if ($error =~ /not/){
      print "Messages From dz_audit_backup...\n";
      print "$error\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList1\@canpar.com
Subject: dz_audit_backup

$error
EOF
`;
   }#end of if messages received

