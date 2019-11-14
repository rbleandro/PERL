#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
GetOptions(
    'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 10\n";

my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep load_cmf_data_ilparcel.pl|grep -v grep|grep -v $my_pid|grep -v "vim load_cmf_data_ilparcel.pl"|grep -v "less load_cmf_data_ilparcel.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "\n###Running load_cmf_data_ilparcel to cpiq on Host:".`hostname`."  ###\n";

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute load_cmf_data_ilparcel' 2>&1`;

#print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From load_cmf_data_ilparcel.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: IQ load_cmf_data_ilparcel.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ load_cmf_data_ilparcel.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

