#!/usr/bin/perl -w

use strict;
use warnings;

my $finTime = localtime();

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'SET TEMPORARY OPTION DATE_ORDER='MDY';execute reload_ups_shipment;' 2>&1`;

if ($dbsqlOut =~ /Could not/ || $dbsqlOut =~ /Cannot/ || $dbsqlOut =~ /SQLCODE/){
     print "Messages From reload_eng_temp.pl at $finTime...\n";
     print "$dbsqlOut\n";

     #open(MAIL, "|/usr/sbin/sendmail -t");
     #print MAIL "To: CANPARDatabaseAdministratorsStaffList\@canpar.com\n";
     #print MAIL "From: cpiq\@canpar.com\n";
     #print MAIL "Subject: ERROR: IQ reload_ups_shipment.pl...ABORTED.\n";
     #print MAIL "Content-Type: text/html\n";
     #print MAIL "MIME-Version: 1.0\n\n";
     #print MAIL "<p>$dbsqlOut</p><p>Script path: perl $0</p>";
     #close(MAIL);
     exit;
}

$finTime = localtime();
print "Completed Successfully at $finTime!!\n";
