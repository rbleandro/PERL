#!/usr/bin/perl -w

#Usage Restrictions
if ($#ARGV < 1){
   print "Usage: dump_databases_to_test.pl originDB destDB rleandro\@canpar.com 1\n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

my $option = $ARGV[3];
my $dba = $ARGV[2];

if (defined $dba) {
    $mail=$dba;
} else {
    $mail='CANPARDatabaseAdministratorsStaffList';
}

if (defined $option) {
    $option=$option;
} else {
    $option=0;
}

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}

use Sys::Hostname;
$prodserver = hostname();
$testserver = '10.3.1.165';

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

#$my_pid = getppid();
#$isProcessRunning =`ps -ef|grep sybase|grep dump_databases.pl|grep -v grep|grep -v $my_pid|grep -v "vim dump_databases.pl"|grep -v "less dump_databases.pl"`;

#print "My pid: $my_pid\n";
#print "Running: $isProcessRunning \n";
#
#if ($isProcessRunning){
#die "\n Can not run, previous process is still running \n";
#
#}else{
#print "No Previous process is running, continuing\n";
#}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Cleaning up the backup volume to free space (deletes all files older than 7 days)
$deleteoldfiles =`sudo find /home/sybase/db_backups/ -mindepth 1 -mtime +60 -delete`;

$originDB = $ARGV[0];
$destDB = $ARGV[1];


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
dump database $originDB to "/home/sybase/db_backups/$originDB.dmp" compression=100
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_test at $finTime

$sqlError
EOF
`;
die;
}

#Copying files to TEST server
$scpError=`scp -p /home/sybase/db_backups/$originDB.dmp sybase\@$testserver:/home/sybase/db_backups`;
print "$scpError\n";

if ($option == 1){

#Loading databases into TEST server
$load_msgs = `ssh $testserver /opt/sap/cron_scripts/load_databases_to_test.pl $originDB $destDB $mail`;

print "$load_msgs \n";
}
else {
print "Database was dumped and the file copied to the destination server but Load was not processed. Do it manually.\n"
}

$finTime = localtime();
print "Time Finished: $finTime\n";
