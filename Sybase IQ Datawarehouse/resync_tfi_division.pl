#!/usr/bin/perl -w

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep tfi_division.pl|grep -v grep|grep -v $my_pid|grep -v "vim tfi_division.pl"|grep -v "less tfi_division.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_tfi_division' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From tfi_division.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ tfi_division.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ tfi_division.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

