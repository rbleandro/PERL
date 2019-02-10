#!/usr/bin/perl 

###################################################################################
#Script:   This script runs cost analysis                                         #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#02/03/07       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

#Store inputs
$server = $ARGV[0];
$filename = $ARGV[1];
$date1 = $ARGV[2];
$date2 = $ARGV[3];

print "Before:$date1\n$date2\n";

# Add single quotes for the IQ proc
$date1 = "\"'".$date1."'\"";
$date1 =~ s/\//\\\\\//g;

$date2 = "\"'".$date2."'\"";
$date2 =~ s/\//\\\\\//g;

print "After:$date1\n$date2\n";
print "Starting recalc process on IQ...".localtime()."\n";

# Extract the name to use for email from filename
$email_add = substr($filename,0,length($filename)-7);

print "***Initiating BCP FROM ASE for cost_analysis At:".localtime()."***\n";
$bcpError = `/opt/sybase/OCS-15_0/bin/bcp tempdb2.guest.$filename out /opt/sybase/bcp_data/cmf_data/$filename.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -c -t"|:|" -r"\n" 2>&1`;


if ($bcpError =~ /Msg/ || $bcpError =~ /error/i){
      print "Messages From cost_analysis...\n";
      print "$bcpError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: BCP ERROR: cost_analysis

$bcpError
EOF
`;
}else{ print "$bcpError\n"; }

#Recording the number of records being loaded
$rec_cnt = `wc -l /opt/sybase/bcp_data/cmf_data/$filename.dat`;
$rec_cnt =~ s/^\s+//g;
@cnt=split(/\s/,$rec_cnt);

print $cnt[0]."\n";
print "***Initiating LOAD TO IQ for cost_analysis At:".localtime()."***\n";

##### Create a temp file for the specified filename #####
$sedError0 = `sed -e s/param0/"'"$email_add"'"/ /opt/sybase/cron_scripts/sql/load_imported_cost_analysis.sql > /tmp/load_imported_$filename.4.sql`;
$sedError1 = `sed -e s/param1/"$date1"/ /tmp/load_imported_$filename.4.sql > /tmp/load_imported_$filename.3.sql`;
$sedError2 = `sed -e s/param2/"$date2"/ /tmp/load_imported_$filename.3.sql > /tmp/load_imported_$filename.2.sql`;
$sedError3 = `sed -e s/param3/$cnt[0]/ /tmp/load_imported_$filename.2.sql > /tmp/load_imported_$filename.1.sql`;
$sedError4 = `sed -e s/filename/$filename/ /tmp/load_imported_$filename.1.sql > /tmp/load_imported_$filename.sql`;
print "sed0-$sedError0\nsed1-$sedError1\nsed2-$sedError2\nsed3-$sedError3\nsed4-$sedError4\n";

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=$email_add;pwd=" -host localhost -port 2638 -nogui -onerror exit /tmp/load_imported_$filename.sql 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From cost_analysis...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: cost_analysis

$dbsqlOut
EOF
`;
}
