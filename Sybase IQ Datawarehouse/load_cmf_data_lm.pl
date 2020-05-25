#!/usr/bin/perl -w


#Script:   This script keeps track of the database growth and percent increase in
#          db size from the last reading taken
#
#02/03/04	      Amer Khan	      Originally created
#May 14 2020      Rafael Bahia      Added support for script parameters      

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
my $mail = 'CANPARDatabaseAdministratorsStaffList';

GetOptions(
      'to|r=s' => \$mail
) or die "Usage: $0 --to|r rleandro \n";

print "\n###Running cmf_data load to cpiq on Host:".`hostname`."  ###\n";

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute load_cmf_data_lm_from_ase' 2>&1`;

print "$dbsqlOut\n";

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From Load cmf_data_lm from ASE...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: Load cmf_data_lm from ASE...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***Load cmf_data_lm from ASE...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

