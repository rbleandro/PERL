#!/usr/bin/perl -w


#Script:        This script loads data into master_record on monthly
#Author:	Amer Khan
#Date           Name            Description
#Feb 29 2016    Amer Khan       Created
#Apr 30 2020    Rafael Bahia    Changed db conn to use cronmpr user to allow separate tempdb usage

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
$isProcessRunning =`ps -ef|grep sybase|grep mpr_data_load_master_record.pl|grep -v grep|grep -v $my_pid|grep -v "vim mpr_data_load_master_record.pl"|grep -v "less mpr_data_load_master_record.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use mpr_data
go
declare \@fiscal int
select \@fiscal= (period - 1) from cmf_data..tot_pe where year =year(getdate()) and getdate() between start_date and end_date
if \@fiscal = 0 select \@fiscal = 12
exec load_master_record \@fiscal
go
use mpr_data_lm
go
declare \@fiscal int
select \@fiscal= (period - 1) from cmf_data_lm..tot_pe where year =year(getdate()) and getdate() between start_date and end_date
if \@fiscal = 0 select \@fiscal = 12
exec load_master_record \@fiscal
go
exit
EOF
`;

if ($sqlError =~ /Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - mpr_data_load_master_record at $finTime

$sqlError
EOF
`;
}
$finTime = localtime();
print "Time Finished: $finTime\n";
print "Any messages.............\n";
print "*******************\n $sqlError \n********************\n";

