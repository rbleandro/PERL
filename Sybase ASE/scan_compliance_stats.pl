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
$isProcessRunning =`ps -ef|grep sybase|grep scan_compliance_stats.pl|grep -v grep|grep -v $my_pid|grep -v "vim scan_compliance_stats.pl"|grep -v "less scan_compliance_stats.pl"`;

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
use scan_compliance
go
declare \@startdate date
declare \@enddate date

set \@enddate = dateadd(dd,-7,getdate())
set \@startdate = dateadd(dd,-8,getdate())

execute ScanComplianceStats \@startdate, \@enddate,0

select 'Procedure ScanComplianceStats executed for start date = ' + convert(varchar(50),\@startdate) + ' and end date = ' + convert(varchar(50),\@enddate)
go
exit
EOF
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/ || $sqlError =~ /error/i){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error: scan_compliance_stats at $finTime

$sqlError

This script's name is scan_compliance_stats.pl and is located at the default cron_scripts folder.

EOF
`;
}
else{
print $sqlError."\n";
}
#rleandro
#CANPARDatabaseAdministratorsStaffList