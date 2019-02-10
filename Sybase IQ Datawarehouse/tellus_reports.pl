#!/usr/bin/perl -w

###################################################################################
#Script:   This script monitors sybase server errorlog for critical and fatal     #
#                                                                                 #
#Author:    Ahsan Ahmed                                                           #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#01/07/04       Ahsan Ahmed     Originally created                                #
#                                                                                 #
#02/23/06      Ahsan Ahmed      Modified for email to DBA's and documentation     #
###################################################################################


print "\n**********Starting Tellus load now...".localtime()."*************\n\n";
#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


$cpError  = `./remove_header.pl /opt/sybase/tmp/accsum.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/er.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/toll.csv`;
$cpError  = `./remove_header.pl /opt/sybase/tmp/occ.csv`;
print "cpError: $cpError\n";

#die "stopped\n";

$dbsqlOut = `. /opt/sybase/SYBASE.sh
. /opt/sybase/iQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_accsum.sql`;

#die "Unziped, copy, removed header and imported data to IQ\n";

$dbsqlOut = `. /opt/sybase/SYBASE.sh
. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_occ.sql`;

$dbsqlOut = `. /opt/sybase/SYBASE.sh
. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_er.sql`;

$dbsqlOut = `. /opt/sybase/SYBASE.sh
. /opt/sybase/IQ-15_4/IQ-15_4.sh

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/load_toll.sql`;
#Roving old csv files to ensure that we have the latest csv files.

#$rmDone = `rm /opt/sybase/tmp/*.csv`;


`/usr/sbin/sendmail -t -i <<EOF

To: CANPARDatabaseAdministratorsStaffList\@canpar.com

Subject:  -  Tellus files have been imported to IQ.

Tellus files have been imported to IQ. Please check.
EOF
`;

