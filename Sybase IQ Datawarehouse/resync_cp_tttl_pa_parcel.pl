#!/usr/bin/perl -w
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
my $mail = 'CANPARDatabaseAdministratorsStaffList';

GetOptions(
      'to|r=s' => \$mail
) or die "Usage: $0 --to|r rleandro\n";

my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep resync_cp_tttl_pa_parcel.pl|grep -v grep|grep -v $my_pid|grep -v "vim resync_cp_tttl_pa_parcel.pl"|grep -v "less resync_cp_tttl_pa_parcel.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'execute resync_cp_tttl_pa_parcel' 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From resync_cp_tttl_pa_parcel.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: IQ resync_cp_tttl_pa_parcel.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ resync_cp_tttl_pa_parcel.pl...Aborting Now!!***\n\n";
}

print "Completed Successfully!!\n";

