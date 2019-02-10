#!/usr/bin/perl -w

###################################################################################
#Script:   This script load_canada_post_table                                     #
#                                                                                 #
#										  #
#Author:   Amer Arain                                                             #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Oct 26,2017	Amer Arain	Originally created                                #
#                                                                                 #
###################################################################################

#Check if the process is still running from last scheduled time
#if (1==2){
$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep load_canada_post_table.pl|grep -v sh|grep -v grep|grep -v $my_pid|grep -v "vim load_canada_post_table.pl"|grep -v "less load_canada_post_table.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


print "***Initiating IQ procedure load_canada_post_table At:".localtime()."***\n";

$dbsqlError = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute load_canada_post_street_address_from_ASE' 2>&1`;

if ($dbsqlError =~ /Error/ || $dbsqlError =~ /error/ || $dbsqlError =~ /not/){
      print "Messages From load_canada_post_table...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
From: IQAdmin\@CPIQ2.com
Subject: Canpar - load_canada_post_table

$dbsqlError
EOF
`;
}else{
   print $dbsqlError;
}

