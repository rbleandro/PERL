#!/usr/bin/perl -w

use strict;
use warnings;
use Sys::Hostname;

my @prodline ="";

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}

my $prodserver = hostname();

#Set starting variables
my $currTime = localtime();
my $startHour=sprintf('%02d',((localtime())[2]));
my $startMin=sprintf('%02d',((localtime())[1]));

my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep copy_h_barcode_scans_from_lmscan.pl|grep -v grep|grep -v $my_pid|grep -v "vim copy_h_barcode_scans_from_lmscan.pl"|grep -v "less copy_h_barcode_scans_from_lmscan.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "copy_h_barcode_scans_from_lmscan StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

my $sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
set clientapplname 'copy_h_barcode'
go
use cpscan
go
exec copy_h_barcode_scans_from_lmscan null,null
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /Msg/){
print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - copy_h_barcode_scans_from_lmscan

Following status was received during copy_h_barcode_scans_from_lmscan that started on $currTime
$sqlError
EOF
`;
$currTime = localtime();
print $currTime . "\n";
}
$currTime = localtime();
print "copy_h_barcode_scans_from_lmscan FinTime: $currTime\n";

