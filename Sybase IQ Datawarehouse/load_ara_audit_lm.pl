#!/usr/bin/perl -w

print "\n###Running load_ara_audit_lm on Host:".`hostname`."  ###\n";

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'exec load_ara_audit_lm' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From Load load_ara_audit_lm from ASE...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: load_ara_audit_lm...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***load_ara_audit_lm from ASE...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

