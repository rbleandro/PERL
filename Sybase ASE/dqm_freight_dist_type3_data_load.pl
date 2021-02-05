#!/usr/bin/perl -w

#Script:   		This script load dist_frt data in dqm_data_lm every week.
#Date           Name            Description
#Sep 20	2016	Amer Khan		Originally Created
#Oct 12 2020	Rafael			Removed obsolete code; improved logging

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

$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));


$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep dqm_freight_dist_type3_data_load.pl|grep -v grep|grep -v $my_pid|grep -v "vim dqm_freight_dist_type3_data_load.pl"|grep -v "less dqm_freight_dist_type3_data_load.pl"`;

print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver <<EOF 2>&1
use dqm_data_lm
go
exec dqm_freight_dist_type3_data_load
go
exit
EOF
`;

$finTime = localtime();
print "Any message from the proc execution...\n\n $sqlError \n\n finish time: $finTime\n\n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/ || $sqlError =~ /error/i){
if ( $sqlError =~ /Msg 2601/){die;}

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error: dqm_freight_dist_type3_data_load at $finTime

$sqlError
EOF
`;
}
