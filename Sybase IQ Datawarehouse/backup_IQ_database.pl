#!/usr/bin/perl -w

###################################################################################
#Script:   This script backs up database once week on Sunday                      #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Mar 03,2010	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

print "***Initiating Full Backup At:".localtime()."***\n";

#Removing old backup files...
`rm -f /opt/sybase/db_backups/old_IQ_backup/*`;

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "BACKUP DATABASE CRC OFF ATTENDED OFF BLOCK FACTOR 30 FULL TO '/opt/sybase/db_backups/old_IQ_backup/DB_BACKUP' SIZE 10000000" 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/i || $dbsqlOut =~ /not/i || $dbsqlOut !~ /Execut/i){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Messages During IQ DB Backup

$dbsqlOut
EOF
`;

}
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Successful Messages During IQ DB Backup

$dbsqlOut
EOF
`;

