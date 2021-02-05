#!/usr/bin/perl -w

#Script:   		This script loads data for a table in IQ using a stored procedure in the database
#Author:   		Rafael Leandro
#Date			Name			Description
#Oct 13 2020	Rafael Leandro	Created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';

GetOptions(
    'to|r=s' => \$mail
) or die "Usage: $0 --to|r rleandro \n";


my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_lm_cparf06i' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_lm_cparf06i.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: IQ resync_lm_cparf06i.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_lm_cparf06i.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

