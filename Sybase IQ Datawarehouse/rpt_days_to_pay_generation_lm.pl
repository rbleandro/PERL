#!/usr/bin/perl -w

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'exec dba.rpt_days_to_pay_generation_lm' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From rpt_days_to_pay_generation_lm...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: rpt_days_to_pay_generation_lm ...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***rpt_days_to_pay_generation_lm...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

