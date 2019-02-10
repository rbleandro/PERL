#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates points_no_ranges table in cmf_data            #
#                                                                            #
#Author:   Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2006/12/11	Amer Khan	Originally created                           #
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$checkFlag = `cat /tmp/points_no_ranges_status`;
$sqlError = ""; # Initialize Var
if ($checkFlag == '1'){
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB2 -b -n<<EOF 2>&1
use cmf_data
go
set replication off
go
execute update_points_no_ranges
go
select * into #postal_codes from points where PCode_From = PCode_To
go
select * into #postal_2 from #postal_codes where datalength(rtrim(PCode_From)) = 6
go
select * into #postal_3 from #postal_2 t2
where t2.PCode_From not in (select postal_code from points_no_ranges where postal_code = t2.PCode_From)
go
insert into points_no_ranges
select t3.Terminal, t3.Interline, t3.City, t3.Delay, t3.Service, t3.Week1, t3.Week2, t3.PCode_From, t3.PCode_To, t3.Additional_Days, 
t3.Sort_Terminal, t3.Point_Served, '', '', '' from #postal_3 t3
go
exit
EOF
`;
print $sqlError."\n";

}

if($sqlError =~ /no|not/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating points_no_ranges

Following status was received during updating points_no_ranges that started on $currTime
$sqlError
EOF
`;
}
`echo 0 > /tmp/points_no_ranges_status`;
$currTime = localtime();
print "FinTime: $currTime\n";
