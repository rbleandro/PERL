#!/usr/bin/perl -w

my $finTime = localtime();

#$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
#dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'truncate table eng_temp_temp' 2>&1`;

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute reload_eng_temp' 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
     print "Messages From reload_eng_temp.pl at $finTime...\n";
     print "$dbsqlOut\n";

#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: ERROR: IQ reload_eng_temp.pl...ABORTED!!
#
#$dbsqlOut
#EOF
#`;
die "\n\n*** IQ reload_eng_temp.pl...Aborting Now!!***\n\n";
}


$finTime = localtime();
print "Completed Successfully at $finTime!!\n";
