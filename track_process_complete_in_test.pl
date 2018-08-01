#!/usr/bin/perl -w

##############################################################################
#Note:     This scrip willmodify tttl_ma_shipment  weight field in cpscan    #
#Author:   Ahsan Ahmed                                                      #                                                    
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#02/23/06     Ahsan Ahmed     Added comments and email for DBA's             # 
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$spid = $ARGV[0];

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPSYBTEST -b -n<<EOF 2>&1
while ((select 1 from master..sysprocesses where spid=$spid)=1 )
begin
waitfor delay "00:01:10"
end
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com 
Subject: It was done at $finTime 

$sqlError
EOF
`;
