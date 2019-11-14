#!/usr/bin/perl -w

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute purge_tttl_ev_event' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From purge_tttl_ev_event.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ purge_tttl_ev_event.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ purge_tttl_ev_event.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

