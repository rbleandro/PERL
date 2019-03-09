#!/usr/bin/perl -w

print "\n###Running hub_scan_pcs_generation on Host:".`hostname`."  ###\n";

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "exec hub_scan_pcs_generation null, null, 1, null, 'N'" 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From Load CMF Data from ASE...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: hub_scan_pcs_generation...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***Load CMF Data from ASE...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

