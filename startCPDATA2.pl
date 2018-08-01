#!/usr/bin/perl -w

###################################################################################
#Script:   This script starts Sybase ASE, you must be a valid user belonging      #
#          sybase group in order to shutdown Sybase Servers.                      #
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
#$server = 'CPDATA2';

print "\n\n***Initiating Server Start On CPDATA2 at:".localtime()."***\n";
#Server must be started under sybase user
$inError = `su -c '/opt/sybase/ASE-15_0/install/startserver -f /opt/sybase/ASE-15_0/install/RUN_CPDATA2' sybase`;

sleep(0);

print "\nMessages From Server Start Process...\n";
print "$inError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Server Start Process Initiated!!

Server Start Process Initiated By \`whoami\` at $currTime On CPDATA1
$inError
EOF
`;
