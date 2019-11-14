#!/usr/bin/perl -w

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'truncate table eng_temp_temp' 2>&1`;

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'LOAD TABLE eng_temp_temp ( col_text_1) FROM '/opt/sybase/bcp_data/eng_temp.csv' DELIMITED BY 0x2c ROW DELIMITED BY 0x0d0a ESCAPES OFF QUOTES ON FORMAT ASCII' 2>&1`;

#print "$dbsqlOut\n";
#if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
#      print "Messages From reload_eng_temp.pl...\n";
#      print "$dbsqlOut\n";
#
#`/usr/sbin/sendmail -t -i <<EOF
#To: rleandro\@canpar.com
#Subject: ERROR: IQ reload_eng_temp.pl...ABORTED!!
#
#$dbsqlOut
#EOF
#`;
#die "\n\n*** IQ reload_eng_temp.pl...Aborting Now!!***\n\n";
#}

print "Completed Successfully!!\n";

