#!/usr/bin/perl -w

print "\n###Running cmf_data load to cpiq on Host:".`hostname`."  ###\n";

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_cp_revhst_bcxref' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_cp_revhst_bcxref.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ resync_cp_revhst_bcxref.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_cp_revhst_bcxref.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

