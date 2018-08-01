#!/usr/bin/perl 

###################################################################################
#Script:   This script starts Sybase backup server, you must be a valid user      #
#          belonging to sybase group in order to start Sybase Servers.            #
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
$inError = `su -c '/opt/sybase/ASE-15_0/install/startserver -f /opt/sybase/ASE-15_0/install/RUN_CPDB1_back' sybase`;

print "\nMessages From Backup Server Start Process...\n";
print "$inError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Backup Server Start Process Initiated On CPDB1!!

Backup Server Start Process Initiated By \`whoami\` at $currTime On CPDB1
$inError
EOF
`;
