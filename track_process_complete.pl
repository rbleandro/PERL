#!/usr/bin/perl
##############################################################################
#Note:     This scrip willmodify tttl_ma_shipment  weight field in cpscan    #
#Author:   Ahsan Ahmed                                                      #                                                    
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#02/23/06     Ahsan Ahmed     Added comments and email for DBA's             # 
##############################################################################

#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$spid = "0";
# Are there processes to monitor? If a spid is given in there then check for it, if it disappears that remove it
#Add a spid to monitor in this file
open (SPID,"</opt/sybase/cron_scripts/track_processes") or die "Can't Open track_processes file: $!\n\n";

while (<SPID>){
   @spidLine = split(/\t/,$_);
   $spidLine[0] =~ s/\n//g;
   $spid = $spidLine[0]; 
}

if ($spid == "0") {die;} 

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -b -n<<EOF 2>&1
use cpscan
go
if exists (select 1 from master..sysprocesses where spid=$spid and status in ("running","sleeping"))
begin
select 'Still Running'
end
go
exit
EOF
`;

$finTime = localtime();

if ($sqlError !~ /Running/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Proc  was done at $finTime 

$sqlError
EOF
`;

#remove the spid from track_processes now, that it has completed...
`cat /dev/null > /opt/sybase/cron_scripts/track_processes`;
}
