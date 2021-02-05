#!/usr/bin/perl -w

##############################################################################
#Script:   This script purges overhead_package_scans data older than 60 days #
#                                                                            #
#Author:	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#Feb 1 2017	Amer Khan	Created					     #
##############################################################################

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

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute Purge overhead_package_scans


$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver <<EOF 2>&1
use sort_data
go
if datename(dw,getdate()) = 'Sunday'
begin
set rowcount 2500000
delete sort_data..overhead_package_scans
from sort_data..overhead_package_scans (index idxupd) where updated_on < dateadd(dd, -45, getdate())
end
else
begin
set rowcount 150000
delete sort_data..overhead_package_scans
from sort_data..overhead_package_scans (index idxupd) where updated_on < dateadd(dd, -45, getdate())
end
go
exit
EOF
`;
if ($sqlError =~ /Msg/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - Purge overhead_package_scans at $finTime

$sqlError
EOF
`;
}
$finTime = localtime();
print "Time Finished: $finTime\n";
