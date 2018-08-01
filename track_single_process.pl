#!/usr/bin/perl
##############################################################################
#Note:     Track one process for completion and reports its sttaus every hour#
#Author:   Amer Khan                                                         #                                                    
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#Aug 9, 2012	Amer Khan	Created 			             # 
##############################################################################
#									     #
#									     #
#TO START, BE SURE REMOVE THE FILE FROM /TMP FOR THAT SPID, eg: rm /tmp/4180 #
#									     #
#									     #
##############################################################################
#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Usage Restrictions
if ($#ARGV < 2){
   print "Usage: track_single_process.pl spid subject email  \n";
   print " Eg: track_single_process.pl 4180 MPR akhan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

$spid=$ARGV[0];
$subject=$ARGV[1];
$notify=$ARGV[2];

#Check notification flag first...
$notify_flag = "0"; #initialiaze var
$notify_flag = `cat /tmp/$spid`;
print "$notify_flag \n";

if (($notify_flag =~ /0/ && -e "/tmp/$spid") || !(-e "/tmp/$spid"))
{
`echo 0 > /tmp/$spid`;
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB2 -b -n<<EOF 2>&1
use cpscan
go
if exists (select 1 from master..sysprocesses where spid=$spid and status not in ('recv sleep','LOG SUSPEND'))
begin
select 'Still Running'
end
else
select status from master..sysprocesses where spid=$spid
go
exit
EOF
`;

$finTime = localtime();

if ($sqlError !~ /Running/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $notify\@canpar.com
Subject: $subject status changed at $finTime 

$sqlError
EOF
`;
print "$sqlError \n";
`echo 1 > /tmp/$spid`;
}
else{ `echo 0 > /tmp/$spid`;
print "$sqlError \n";
}
}#eof big if
