#!/usr/bin/perl -w

print "\n###Running loadEigenCCPayments on Host:".`hostname`."  ###\n";

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'exec loadEigenCCPayments' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From Load loadEigenCCPayments from ASE...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: loadEigenCCPayments...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***loadEigenCCPayments from ASE...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

