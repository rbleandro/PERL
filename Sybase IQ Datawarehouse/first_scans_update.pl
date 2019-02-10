#!/usr/bin/perl -w

###################################################################################
#Script:   This script updates first_scans in IQ on hourly basis                  #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Dec 17,2007	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Check if the process is still running from last scheduled time
$isProcRunning =`ps -ef|grep sybase|grep dbisql|grep update_first_scans|grep -v sh`;
if($isProcRunning){
die "Process is still running...dying now";
   }


print "***Initiating IQ procedure update_first_scans At:".localtime()."***\n";

$dbsqlError = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute update_first_scans'

dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "update tttl_ma_manifest_2010 set consignee_postalcode = replace(consignee_postalcode,' ','') where conv_time_date > 'January 1 2010'"  2>&1`;

print "$dbsqlOut\n";
if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/){
      print "Messages From first_scans updates...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: first_scans updates

$dbsqlError
EOF
`;
}else{
   print $dbsqlError;
}
