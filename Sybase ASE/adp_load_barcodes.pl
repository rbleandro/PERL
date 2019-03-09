#!/usr/bin/perl -w

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
use Sys::Hostname;
$prodserver = hostname();


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));


$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep adp_load_barcodes.pl|grep -v grep|grep -v $my_pid|grep -v "vim adp_load_barcodes.pl"|grep -v "less adp_load_barcodes.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use lmscan
go
exec adp_load_barcodes null, null
go   
exit
EOF
`;

print "Any message from the proc execution...\n $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/ || $sqlError =~ /error/i){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: Error: adp_load_barcodes at $finTime

$sqlError

This script's name is adp_load_barcodes.pl and is located at the default cron_scripts folder.

EOF
`;
}


$day=sprintf('%02d',((localtime())[6]));
$day= int($day);

if ($day eq 7){
`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com;jim_pepper\@canpar.com;Glenn.McFarlane\@loomis-express.com
Subject: Reminder: adp_load_barcodes is still running.

This is just to remind you that this is still running. Should we disable it?

EOF
`;
}else{
print "Not emailing, because today is not Sunday \n";
}
