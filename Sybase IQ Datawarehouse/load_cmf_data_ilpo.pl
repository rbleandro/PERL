#!/usr/bin/perl -w

###################################################################################
#Script:   This script keeps track of the database growth and percent increase in #
#          db size from the last reading taken                                    #
#                                                                                 #
#Note:     This script can be used with any database, but you have to have a table#
#          called db_growth_record in the database where it is being executed     #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

print "\n###Running cmf_data load to cpiq on Host:".`hostname`."  ###\n";

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute load_cmf_data_ilpo' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From load_cmf_data_ilpo.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ load_cmf_data_ilpo.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ load_cmf_data_ilpo.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

