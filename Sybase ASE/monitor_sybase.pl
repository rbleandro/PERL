#!/usr/bin/perl

###################################################################################
#Script:   This script monitors sybase Database                                   #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#11/01/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
use Sys::Hostname;
$prodserver = hostname();

if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}else{
   $standbyserver = "CPDB2";
}

#Setting Sybase environment is set properly
#require "/opt/sap/cron_scripts/set_sybase_env.pl";

#Execute sybase Monitoring
$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$standbyserver -l180 -n -b <<EOF 2>&1
exit
EOF
`;

print $error;
if ($error) {
print "sybase frozen   Error: $error and hostname: $standbyserver \n";
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Sybase Server not responding on $standbyserver!!!

Sybase Server may be down on $standbyserver
******
$error \`date\`
******
EOF
`;
}
