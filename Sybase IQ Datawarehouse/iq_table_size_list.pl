#!/usr/bin/perl -w
#=============================================
# iq_space_list.pl
#
# Change settings below for your server.
#=============================================

print "==============================================";
print "\nGenerate space SP calls ..";
print "\n==============================================";

#`. /opt/sybase/IQ-16_0/IQ-16_0.sh
#dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute generate_iqtablesize_commands' > /opt/sybase/cron_scripts/space.txt`;

`. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute generate_iqtablesize_commands' > /opt/sybase/cron_scripts/iqtablesize.sql`;

#print "==============================================";
#print "\nPrep SQL File ..";
#print "\n==============================================";

`grep iqtable /opt/sybase/cron_scripts/iqtablesize.sql | awk '{ print \$0 } ' > /opt/sybase/cron_scripts/iqtablesize2.sql`;
#; print "go";
print "\n==============================================";
print "\nRun SQL File to alter the procedure";
print "\n==============================================";

$dbsqlOut=`. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit '/opt/sybase/cron_scripts/iqtablesize2.sql' 2>&1`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/){
      print "Messages From iq_table_size_list.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: ERROR: IQ iq_table_size_list.pl - alter procedure stage...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ iq_table_size_list.pl...Aborting Now!!***\n\n";
}


print "\n==============================================";
print "\nRun the altered procedure to get the table sizes. Might take a while...";
print "\n==============================================";

$dbsqlOut=`. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit '
set option isql_print_result_set=ALL
go
set option isql_show_multiple_result_sets=On
go
execute iqtablesize' > /opt/sybase/cron_scripts/space.txt`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/){
      print "Messages From iq_table_size_list.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: ERROR: IQ iq_table_size_list.pl - iqtablesize execution phase...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ iq_table_size_list.pl...Aborting Now!!***\n\n";
}

print "==============================================";
print "\nFormat the final output while sorting by size.";
print "\n==============================================";

$catout=`cat /opt/sybase/cron_scripts/space.txt | egrep -v '\\-\\-\\-' | egrep -v 'Tablename|rows\\)|\\.|econds' | awk '{ print \$4 " " \$1 "." \$2 } ' | sort -n`;

$catout =~ s/\s\.\s//g;

my $filename = "/opt/sybase/cron_scripts/table_size_list.txt";
open my $fh, ">", $filename or die("Could not open file. $!");
print $fh $catout;
close $fh;
#> /opt/sybase/cron_scripts/table_size_list.txt`;

print "==============================================";
print "\nCleaning up";
print "\n==============================================";

`rm /opt/sybase/cron_scripts/iqtablesize.sql`;
`rm /opt/sybase/cron_scripts/iqtablesize2.sql`;
`rm /opt/sybase/cron_scripts/space.txt`;
print "\nDONE.\n";