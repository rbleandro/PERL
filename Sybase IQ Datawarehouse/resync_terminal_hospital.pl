#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
GetOptions(
    'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 10\n";

my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep resync_terminal_hospital.pl|grep -v grep|grep -v $my_pid|grep -v "vim resync_terminal_hospital.pl"|grep -v "less resync_terminal_hospital.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "\n###Running resync_terminal_hospital to cpiq on Host:".`hostname`."  ###\n";

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_terminal_hospital' 2>&1`;

#print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_terminal_hospital.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: IQ resync_terminal_hospital.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_terminal_hospital.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

