#!/usr/bin/perl -w

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_lm_CounterBilling' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_lm_CounterBilling.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ resync_lm_CounterBilling.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_lm_CounterBilling.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

