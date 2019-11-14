#!/usr/bin/perl -w

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep resync_cp_tttl_ma_manifest.pl|grep -v grep|grep -v $my_pid|grep -v "vim resync_cp_tttl_ma_manifest.pl"|grep -v "less resync_cp_tttl_ma_manifest.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_cp_tttl_ma_manifest' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_cp_tttl_ma_manifest.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ resync_cp_tttl_ma_manifest.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_cp_tttl_ma_manifest.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

