#!/usr/bin/perl -w

#Script:   	This script loads data for a table in IQ using a stored procedure in the database
#
#Author:   	Rafael Leandro
#Revision:
#Date			Name			Description
#---------------------------------------------------------------------------------
#Aug 16 2019	Rafael Leandro	Created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';

GetOptions(
    'to|r=s' => \$mail
) or die "Usage: $0 --to|r rleandro \n";


my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_cp_cwlink' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_cp_cwlink.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: IQ resync_cp_cwlink.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_cp_cwlink.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

