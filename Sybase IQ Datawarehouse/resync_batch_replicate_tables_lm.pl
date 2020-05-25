#!/usr/bin/perl -w

###################################################################################
#Script:   This script resyncs batch replicated tables                            #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Apr 18,2011	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Check if the process is still running from last scheduled time
#if (1==2){
$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep resync_batch_replicate_tables_lm.pl|grep -v sh|grep -v grep|grep -v $my_pid|grep -v "vim resync_batch_replicate_tables_lm.pl"|grep -v "less resync_batch_replicate_tables_lm.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


print "***Initiating IQ procedure resync_batch_replicate_tables At:".localtime()."***\n";

$dbsqlError = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_batch_replicate_tables_lm' 2>&1`;

if ($dbsqlError =~ /Error/ || $dbsqlError =~ /Message/ || $dbsqlError =~ /Could not/){
      print "Messages From resync_batch_replicate_tables...\n";
      print "$dbsqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
From: IQAdmin\@CPIQ2.com
Subject: LOOMIS: resync_batch_replicate_tables_lm

$dbsqlError
EOF
`;
}else{
   print $dbsqlError;
}

