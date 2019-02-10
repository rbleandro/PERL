#!/usr/bin/perl

###################################################################################
#Script:   This script monitors sybase Database                                   #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage:monitor_sybase.pl CPDATA2\n";
   die;
}
#Setting Sybase environment is set properly
#require "/opt/sybase/cron_scripts/set_sybase_env.pl";

#Initialize vars
$server = $ARGV[0];

#Execute sybase Monitoring 
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -n -b -l180 <<EOF 2>&1
exit
EOF
`;

print $error;
if ($error) {
print "sybase frozen   Error: $error and server name: $server \n";
      `touch /tmp/io_$user`;
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Sybase Database is DOWN on server $server!!!

Sybase Database is down on  production.
******
$error \`date\`
******
EOF
`;
}
