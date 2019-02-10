#!/usr/bin/perl 

###################################################################################
#Script:   This script start CPDATA1, you must be a valid user belonging          #
#          sybase group in order to start Sybase Servers.                         #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#01/12/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";

#Set starting variables
$currTime = localtime();
$server = 'CPDATA1';

#Server must be started under sybase user
$inError = `su -c '/opt/sybase/ASE-15_0/install/startserver -f /opt/sybase/ASE-15_0/install/RUN_CPDB1' sybase`;

print "\nMessages From Server Start Process On CPDB1...\n";
print "$inError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Server Start Process Initiated On CPDB1!!

Server Start Process Initiated By \`whoami\` at $currTime On CPDATA1
$inError
EOF
`;
