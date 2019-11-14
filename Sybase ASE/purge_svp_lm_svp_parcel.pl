#!/usr/bin/perl -w

#Script:   This script purges svp_lm..svp_parcel for data older than 2 years
#
#Author:		Amer Khan						     
#Date           Name            Description
#Feb 1 2017		Amer Khan		Created					     
#Aug 18 2019	Rafael Leandro	Changed the query to achieve better performance and also to impose less stress on replication

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
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute Purge svp_lm..svp_parcel

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use svp_lm
go
declare \@count int
set \@count=1000
while \@count > 0
begin
delete top 1000 svp_lm..svp_parcel from svp_lm..svp_parcel (index idx9) where updated_on_cons < dateadd(yy,-2,getdate())
select \@count=\@\@rowcount
waitfor delay '00:00:02'
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
Subject: Errors - Purge svp_lm..svp_parcel at $finTime

$sqlError
EOF
`;
}
$finTime = localtime();
print "Time Finished: $finTime\n";
